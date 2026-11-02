"use strict";

const fs = require("fs");
const path = require("path");

const REPO_ROOT = process.cwd();
const SEED_DIR = path.join(
  REPO_ROOT,
  "elemental-integration",
  "task-engine",
  "schema",
  "seed"
);
const OUTPUT_PATH = path.join(SEED_DIR, "engine-base.seed.json");

function argument(name, fallback) {
  const index = process.argv.indexOf(`--${name}`);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

const taskSourceDir = argument("task-source", path.join(SEED_DIR, "source"));
const engineCapturePath = argument(
  "engine-capture",
  path.join(
    REPO_ROOT,
    "ben",
    "datamap",
    "Consoladate",
    "capture",
    "appDRNp3jByjHVBc9.schema.capture.json"
  )
);
const progressCapturePath = argument(
  "progress-capture",
  path.join(
    REPO_ROOT,
    "elemental-integration",
    "task-engine",
    "task-resolver",
    "Progress_Tracker_base.json"
  )
);

const sourcePaths = {
  currentTasks: path.join(taskSourceDir, "progress-tasks-current.csv"),
  taskRoles: path.join(taskSourceDir, "progress-tasks-roles.csv"),
  richTasks: path.join(taskSourceDir, "progress-tasks-rich.csv"),
  taskGraph: path.join(taskSourceDir, "progress-tasks-graph.csv"),
  engines: path.join(
    REPO_ROOT,
    "elemental-integration",
    "task-engine",
    "task-resolver",
    "reworked",
    "datamap-engines-export.csv"
  ),
  tableConfigs: path.join(
    REPO_ROOT,
    "elemental-integration",
    "task-engine",
    "task-resolver",
    "reworked",
    "datamap-tables-export.csv"
  ),
  fieldConfigs: path.join(
    REPO_ROOT,
    "elemental-integration",
    "task-engine",
    "task-resolver",
    "reworked",
    "datamap-fields-export.csv"
  ),
  keyMap: path.join(
    REPO_ROOT,
    "elemental-integration",
    "task-engine",
    "task-resolver",
    "reworked",
    "datamap-keyMap-export.csv"
  ),
  conflictRules: path.join(
    REPO_ROOT,
    "elemental-integration",
    "task-engine",
    "task-resolver",
    "stepX_conflict_rules (1).csv"
  ),
  officeSubtasks: path.join(taskSourceDir, "office-subtasks.csv"),
  costingInputSchema: path.join(
    REPO_ROOT,
    "costing",
    "schemas",
    "costing-input.schema.json"
  ),
  costingCommonSchema: path.join(
    REPO_ROOT,
    "costing",
    "schemas",
    "costing-common.schema.json"
  ),
  costingSnapshotSchema: path.join(
    REPO_ROOT,
    "costing",
    "schemas",
    "costing-snapshot.schema.json"
  )
};

function requiredFile(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Missing required source file: ${filePath}`);
  }
  return filePath;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(requiredFile(filePath), "utf8"));
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = "";
  let quoted = false;

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];

    if (quoted) {
      if (char === '"' && next === '"') {
        value += '"';
        index += 1;
      } else if (char === '"') {
        quoted = false;
      } else {
        value += char;
      }
      continue;
    }

    if (char === '"') {
      quoted = true;
    } else if (char === ",") {
      row.push(value);
      value = "";
    } else if (char === "\n") {
      row.push(value.replace(/\r$/, ""));
      rows.push(row);
      row = [];
      value = "";
    } else {
      value += char;
    }
  }

  if (value || row.length) {
    row.push(value.replace(/\r$/, ""));
    rows.push(row);
  }

  const headers = (rows.shift() || []).map(header =>
    header.replace(/^\uFEFF/, "")
  );

  return rows
    .filter(candidate => candidate.some(cell => cell !== ""))
    .map(candidate =>
      Object.fromEntries(
        headers.map((header, index) => [header, candidate[index] || ""])
      )
    );
}

function readCsv(filePath) {
  return parseCsv(fs.readFileSync(requiredFile(filePath), "utf8"));
}

function clean(value) {
  return String(value === undefined || value === null ? "" : value).trim();
}

function compact(record) {
  return Object.fromEntries(
    Object.entries(record).filter(([, value]) => {
      if (value === undefined || value === null || value === "") return false;
      if (Array.isArray(value) && !value.length) return false;
      return true;
    })
  );
}

function slug(value) {
  return clean(value)
    .normalize("NFKD")
    .replace(/[^\x00-\x7F]/g, "")
    .replace(/[^A-Za-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .toLowerCase();
}

function normalizeTitle(value) {
  let normalized = clean(value)
    .replace(/^\s*:\s*/, "")
    .replace(/\s+/g, " ")
    .toLowerCase();

  if (normalized === "clam") normalized = "claim";
  return normalized;
}

function splitList(value) {
  return clean(value)
    .split(/[,;\n]+/)
    .map(item => item.trim())
    .filter(Boolean);
}

function splitEventCodes(value) {
  return [...new Set(splitList(value).map(code => code.toUpperCase()))];
}

function bool(value, fallback = false) {
  const normalized = clean(value).toLowerCase();
  if (!normalized) return fallback;
  return !["false", "0", "no", "n", "unchecked"].includes(normalized);
}

function integer(value, fallback = 0) {
  const parsed = Number.parseInt(clean(value), 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function jsonText(value, fallback) {
  const text = clean(value);
  if (!text) return fallback;
  try {
    JSON.parse(text);
    return text;
  } catch {
    return JSON.stringify(value);
  }
}

function mapByTitle(rows) {
  return new Map(rows.map(row => [normalizeTitle(row["Task Title"]), row]));
}

function sourceTableIndex(progressCapture) {
  return new Map(
    (progressCapture.tables || []).map(table => [table.tableId, table])
  );
}

function sourceKeyForTable(table) {
  return `progress-tracker:${slug(table?.tableLabel || table?.tableId)}`;
}

function extractTableId(row) {
  for (const value of Object.values(row)) {
    const match = clean(value).match(/tbl[A-Za-z0-9]+/);
    if (match) return match[0];
  }
  return "";
}

function tableConfigParts(label, engineNames) {
  const match = clean(label).match(/^Step\s+([0-9xX]+)\s+(.+?)\s+\[(.*)\]$/);
  if (!match) {
    return {
      stepCode: "",
      engineName: "",
      role: slug(label)
    };
  }

  const operation = match[2].trim();
  const engineName =
    engineNames
      .slice()
      .sort((left, right) => right.length - left.length)
      .find(name => operation.toLowerCase().startsWith(name.toLowerCase())) ||
    operation;

  return {
    stepCode: `step${match[1].toUpperCase() === "X" ? "X" : match[1]}`,
    engineName,
    role: slug(match[3])
  };
}

function nonBlankColumns(row, prefix) {
  return Object.fromEntries(
    Object.entries(row).filter(
      ([key, value]) => key.startsWith(prefix) && clean(value)
    )
  );
}

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function flattenContractRecord(schemaObject, targetFields) {
  const valuesByPath = new Map();

  function addValue(pathParts, value) {
    const fieldName = pathParts.join(".");
    const textValue =
      typeof value === "string" ? value : JSON.stringify(value);

    if (!valuesByPath.has(fieldName)) {
      valuesByPath.set(fieldName, []);
    }
    const values = valuesByPath.get(fieldName);
    if (!values.includes(textValue)) values.push(textValue);
  }

  function visitObject(object, parentParts) {
    for (const [key, value] of Object.entries(object)) {
      const pathParts = [...parentParts, key];

      if (isPlainObject(value)) {
        visitObject(value, pathParts);
        continue;
      }

      const isObjectArray =
        Array.isArray(value) &&
        value.some(isPlainObject) &&
        value.every(item => item === null || isPlainObject(item));

      if (isObjectArray) {
        for (const item of value) {
          if (isPlainObject(item)) {
            visitObject(item, [...parentParts, `${key}[]`]);
          }
        }
        continue;
      }

      addValue(pathParts, value);
    }
  }

  visitObject(schemaObject, []);

  return Object.fromEntries(
    targetFields
      .filter(field => valuesByPath.has(field.fieldLabel))
      .map(field => {
        const values = valuesByPath.get(field.fieldLabel);
        return [
          field.fieldLabel,
          values.length === 1 ? values[0] : JSON.stringify(values)
        ];
      })
  );
}

function buildSeed() {
  const engineCapture = readJson(engineCapturePath);
  const progressCapture = readJson(progressCapturePath);
  const currentTasks = readCsv(sourcePaths.currentTasks);
  const taskRoles = readCsv(sourcePaths.taskRoles);
  const richTasks = readCsv(sourcePaths.richTasks);
  const taskGraph = readCsv(sourcePaths.taskGraph);
  const engineRows = readCsv(sourcePaths.engines);
  const tableConfigRows = readCsv(sourcePaths.tableConfigs);
  const fieldConfigRows = readCsv(sourcePaths.fieldConfigs);
  const keyMapRows = readCsv(sourcePaths.keyMap);
  const conflictRows = readCsv(sourcePaths.conflictRules);
  const officeSubtaskRows = readCsv(sourcePaths.officeSubtasks);
  const officeSubtaskHeaders = Object.keys(officeSubtaskRows[0] || {});
  const officeChildHeader = officeSubtaskHeaders.find(
    header => header.includes("Child") && header.includes("Subtask")
  );
  const officeMilestoneHeader = officeSubtaskHeaders.find(header =>
    header.includes("Progress Tasks")
  );
  const officeCategoryHeader = officeSubtaskHeaders.find(header =>
    header.includes("Office Task Category")
  );
  const officeSystemsHeader = officeSubtaskHeaders.find(header =>
    header.includes("System Interactions")
  );

  if (
    !officeChildHeader ||
    !officeMilestoneHeader ||
    !officeCategoryHeader ||
    !officeSystemsHeader
  ) {
    throw new Error("Office subtask source is missing expected columns.");
  }
  const costingInputSchema = readJson(sourcePaths.costingInputSchema);
  const costingCommonSchema = readJson(sourcePaths.costingCommonSchema);
  const costingSnapshotSchema = readJson(sourcePaths.costingSnapshotSchema);

  const engineTables = new Map(
    (engineCapture.tables || []).map(table => [table.tableLabel, table])
  );
  const requiredEngineTables = [
    "Systems",
    "Sources",
    "Engines",
    "Engine-Steps",
    "Table-Configs",
    "Field-Configs",
    "JSON-Key-Map",
    "Conflict-Rules",
    "Config-Releases",
    "Project-Events",
    "Resolver-Runs",
    "Run-Log-Entries",
    "Events-Intents",
    "Progress-Tasks",
    "Task-Dependencies",
    "Completion-Rules",
    "Task-Completions",
    "costing-input",
    "costing-common",
    "costing-snapshot"
  ];

  for (const tableName of requiredEngineTables) {
    if (!engineTables.has(tableName)) {
      throw new Error(`Engine capture is missing table "${tableName}".`);
    }
  }

  const richByTitle = mapByTitle(richTasks);
  const rolesByTitle = mapByTitle(taskRoles);
  const graphByTitle = mapByTitle(taskGraph);
  const graphByEventCode = new Map();
  for (const row of taskGraph) {
    for (const eventCode of splitEventCodes(row.EVENT_LOOKUP)) {
      if (!graphByEventCode.has(eventCode)) {
        graphByEventCode.set(eventCode, row);
      }
    }
  }
  const progressTablesById = sourceTableIndex(progressCapture);
  const engineNames = engineRows.map(row => clean(row.Name)).filter(Boolean);

  const taskDrafts = currentTasks.map((current, index) => {
    const titleKey = normalizeTitle(current["Task Title"]);
    const rich = richByTitle.get(titleKey) || {};
    const role = rolesByTitle.get(titleKey) || {};
    const preliminaryEventCodes = splitEventCodes(
      current.EVENT_LOOKUP || rich.EVENT_LOOKUP
    );
    const graph = graphByTitle.get(titleKey) || {};
    const eventGraph =
      titleKey === "claim"
        ? graphByEventCode.get(preliminaryEventCodes[0]) || {}
        : {};
    const sourceRecordId =
      clean(rich["(id)phaseTask"]) ||
      clean(graph["id(🏁phaseTask)"]) ||
      clean(eventGraph["id(🏁phaseTask)"]) ||
      Object.values(eventGraph)
        .map(clean)
        .find(value => /^rec[A-Za-z0-9]+$/.test(value)) ||
      "";
    const phaseTaskId =
      sourceRecordId || `pt:${slug(current["Task Title"])}`;
    const eventCodes = splitEventCodes(
      current.EVENT_LOOKUP || rich.EVENT_LOOKUP || graph.EVENT_LOOKUP
    );
    const requiredDocuments = clean(rich["Required Documents"]);

    return {
      titleKey,
      source: { current, rich, role, graph },
      record: compact({
        phaseTaskId,
        systemKey: "progress-task-v2",
        sourceTaskRecordId: sourceRecordId,
        taskCode: clean(rich.taskCode) || `TASK:${slug(current["Task Title"])}`,
        taskName:
          clean(rich["Task Name"]) ||
          clean(current["Task Title"]).replace(/^[^:]+:\s*/, ""),
        taskTitle: clean(current["Task Title"]),
        phaseId: clean(rich["id(phase)"]),
        phaseNumber:
          clean(rich.PhaseNumber) ||
          clean(current["Phase (from Phase)"]).match(/\d+/)?.[0] ||
          "",
        taskNumber:
          clean(rich.TaskNum) || clean(current["🏁phaseTaskNum"]),
        eventLookup: eventCodes.join(", "),
        eventLookupNormalized: eventCodes.join(","),
        completionScope: "project",
        taskType: clean(rich.TaskType) || clean(rich.Type) || "workflow",
        frequency: clean(rich.Frequency) || "once",
        responsibleRole:
          clean(role.Role) || clean(rich["Responsible Role"]),
        requiredDocuments,
        requiresEvidence: Boolean(requiredDocuments),
        required: bool(rich.Required, false),
        autocompleteRuleJSON: "{}",
        interfaceActionKeysJSON: "[]",
        completionResultJSON: clean(rich["Completion Result"])
          ? JSON.stringify({ text: rich["Completion Result"] })
          : "{}",
        triggerNotes: clean(rich["Triggers/Notes"]),
        sortOrder: index + 1,
        active: true,
        version: "2.1.0"
      })
    };
  });

  const taskByTitle = new Map(
    taskDrafts.map(task => [task.titleKey, task.record])
  );

  function taskIdForTitle(title) {
    return taskByTitle.get(normalizeTitle(title))?.phaseTaskId || "";
  }

  const requirementDraftsByName = new Map();

  function requirementKeyForName(name) {
    return `req:${slug(name)}`;
  }

  function addRequirementDraft(name, details) {
    const normalizedName = normalizeTitle(name);
    if (!normalizedName) return;

    if (!requirementDraftsByName.has(normalizedName)) {
      requirementDraftsByName.set(normalizedName, {
        requirementKey: requirementKeyForName(name),
        requirementName: clean(name),
        categories: new Set(),
        systemInteractions: new Set(),
        sourceMilestoneTitles: new Set(),
        hasChildRequirements: false,
        childOnly: true
      });
    }

    const draft = requirementDraftsByName.get(normalizedName);
    for (const category of details.categories || []) {
      draft.categories.add(category);
    }
    for (const interaction of details.systemInteractions || []) {
      draft.systemInteractions.add(interaction);
    }
    for (const title of details.sourceMilestoneTitles || []) {
      draft.sourceMilestoneTitles.add(title);
    }
    if (details.hasChildRequirements) draft.hasChildRequirements = true;
    if (!details.childOnly) draft.childOnly = false;
  }

  for (const row of officeSubtaskRows) {
    const milestoneTitles = splitList(row[officeMilestoneHeader]);
    const categories = splitList(row[officeCategoryHeader]);
    const systemInteractions = splitList(row[officeSystemsHeader]);
    const childNames = splitList(row[officeChildHeader]);

    addRequirementDraft(row.Name, {
      categories,
      systemInteractions,
      sourceMilestoneTitles: milestoneTitles,
      hasChildRequirements: childNames.length > 0,
      childOnly: false
    });

    for (const childName of childNames) {
      addRequirementDraft(childName, {
        categories,
        systemInteractions,
        sourceMilestoneTitles: milestoneTitles,
        childOnly: true
      });
    }
  }

  const requirementRecords = [...requirementDraftsByName.values()].map(
    draft => ({
      requirementKey: draft.requirementKey,
      systemKey: "progress-task-v2",
      requirementName: draft.requirementName,
      requirementType: "officeSubtask",
      category: [...draft.categories].join(","),
      systemInteractionsJSON: JSON.stringify([...draft.systemInteractions]),
      sourceMilestoneTitlesJSON: JSON.stringify([
        ...draft.sourceMilestoneTitles
      ]),
      hasChildRequirements: draft.hasChildRequirements,
      childOnly: draft.childOnly,
      stateModel: "singleRecord",
      defaultStatus: "Not Started",
      required: true,
      active: true,
      version: "2.1.0"
    })
  );

  const milestoneRequirementRecords = [];
  const milestoneRequirementKeys = new Set();

  function addMilestoneRequirement(record) {
    if (milestoneRequirementKeys.has(record.mappingKey)) return;
    milestoneRequirementKeys.add(record.mappingKey);
    milestoneRequirementRecords.push(record);
  }

  officeSubtaskRows.forEach((row, rowIndex) => {
    const milestoneTitles = splitList(row[officeMilestoneHeader]);
    const categories = splitList(row[officeCategoryHeader]);
    const childNames = splitList(row[officeChildHeader]);
    const parentRequirementKey = requirementKeyForName(row.Name);

    milestoneTitles.forEach((milestoneTitle, milestoneIndex) => {
      const phaseTaskId = taskIdForTitle(milestoneTitle);
      if (!phaseTaskId) {
        throw new Error(
          `Office subtask "${row.Name}" references unknown milestone ` +
            `"${milestoneTitle}".`
        );
      }

      const category =
        categories[milestoneIndex] || categories[0] || "";
      addMilestoneRequirement({
        mappingKey: `${phaseTaskId}|${parentRequirementKey}|direct`,
        systemKey: "progress-task-v2",
        phaseTaskId,
        requirementKey: parentRequirementKey,
        relationshipType: "direct",
        sourceMilestoneTitle: milestoneTitle,
        sourceOfficeSubtask: clean(row.Name),
        category,
        satisfactionMode: "all",
        required: true,
        sortOrder: (rowIndex + 1) * 100 + milestoneIndex * 10,
        active: true
      });

      childNames.forEach((childName, childIndex) => {
        const childRequirementKey = requirementKeyForName(childName);
        addMilestoneRequirement({
          mappingKey:
            `${phaseTaskId}|${childRequirementKey}|child|` +
            parentRequirementKey,
          systemKey: "progress-task-v2",
          phaseTaskId,
          requirementKey: childRequirementKey,
          parentRequirementKey,
          relationshipType: "child",
          sourceMilestoneTitle: milestoneTitle,
          sourceOfficeSubtask: clean(row.Name),
          category,
          satisfactionMode: "all",
          required: true,
          sortOrder:
            (rowIndex + 1) * 100 + milestoneIndex * 10 + childIndex + 1,
          active: true
        });
      });
    });
  });

  for (const task of taskDrafts) {
    const parentTitles = splitList(
      task.source.rich["Parent Task"] ||
        task.source.current["Parent Task"]
    );
    task.record.parentPhaseTaskId = taskIdForTitle(parentTitles[0]);
  }

  const dependencyRecords = [];
  const dependencyKeys = new Set();

  function addDependency(fromId, toId, dependencyType, direction, reason) {
    if (!fromId || !toId || fromId === toId) return;
    const dependencyKey = `${fromId}|${dependencyType}|${toId}`;
    if (dependencyKeys.has(dependencyKey)) return;
    dependencyKeys.add(dependencyKey);
    dependencyRecords.push({
      dependencyKey,
      systemKey: "progress-task-v2",
      fromPhaseTaskId: fromId,
      toPhaseTaskId: toId,
      dependencyType,
      direction,
      reason,
      conditionJSON: "{}",
      priority: 100,
      maxDepth: 5,
      active: true
    });
  }

  for (const task of taskDrafts) {
    const graph = task.source.graph;
    const rich = task.source.rich;
    const fromId = task.record.phaseTaskId;

    for (const targetTitle of splitList(
      graph["Triggers Completion Of"] || rich["Triggers Completion Of"]
    )) {
      addDependency(
        fromId,
        taskIdForTitle(targetTitle),
        "triggersCompletionOf",
        "forward",
        "The source task explicitly triggers completion of the target task."
      );
    }

    for (const prerequisiteTitle of splitList(
      graph["Assume Complete If"] || rich["Assume Complete If"]
    )) {
      addDependency(
        taskIdForTitle(prerequisiteTitle),
        fromId,
        "assumeCompleteIf",
        "reverse",
        "The target task is assumed complete when the source task completes."
      );
    }
  }

  const dependencyTargetsBySource = new Map();
  for (const dependency of dependencyRecords) {
    if (!dependencyTargetsBySource.has(dependency.fromPhaseTaskId)) {
      dependencyTargetsBySource.set(dependency.fromPhaseTaskId, []);
    }
    dependencyTargetsBySource
      .get(dependency.fromPhaseTaskId)
      .push({
        phaseTaskId: dependency.toPhaseTaskId,
        reason: dependency.dependencyType
      });
  }

  for (const task of taskDrafts) {
    task.record.autocompleteRuleJSON = JSON.stringify({
      targets: dependencyTargetsBySource.get(task.record.phaseTaskId) || []
    });
  }

  const completionRuleRecords = [];
  for (const task of taskDrafts) {
    const eventCodes = splitEventCodes(task.record.eventLookup);
    for (const [index, eventLookupCode] of eventCodes.entries()) {
      const documentEvidence = Boolean(task.record.requiredDocuments);
      completionRuleRecords.push({
        completionRuleKey: `${task.record.phaseTaskId}|${eventLookupCode}|project`,
        systemKey: "progress-task-v2",
        phaseTaskId: task.record.phaseTaskId,
        eventLookupCode,
        matchMode: "exact",
        completionScope: "project",
        completionSource: documentEvidence ? "document" : "source",
        requiresEvidence: documentEvidence,
        evidenceType: documentEvidence ? "document" : "event",
        conditionJSON: documentEvidence
          ? JSON.stringify({
              completionEvidence: true,
              requiredDocuments: task.record.requiredDocuments
            })
          : "{}",
        autocompleteRuleJSON: task.record.autocompleteRuleJSON,
        resultJSON: task.record.completionResultJSON || "{}",
        priority: 100 + index,
        active: true
      });
    }
  }

  const configuredTableIds = new Set(
    tableConfigRows.map(extractTableId).filter(Boolean)
  );
  [
    "tblOhnfdIlabxXOqL",
    "tblECgtClvoenWXJn",
    "tbl1mIQg2utmj7Vqt",
    "tbloJ5eN46v1Zx7AG"
  ].forEach(tableId => configuredTableIds.add(tableId));

  const sourceRecords = [...configuredTableIds]
    .map(tableId => progressTablesById.get(tableId))
    .filter(Boolean)
    .map(table => ({
      sourceKey: sourceKeyForTable(table),
      systemKey: "progress-task-v2",
      sourceName: table.tableLabel,
      sourceRole:
        table.tableId === "tblOhnfdIlabxXOqL"
          ? "eventQueue"
          : table.tableId === "tblECgtClvoenWXJn"
            ? "taskPolicy"
            : table.tableId === "tbl1mIQg2utmj7Vqt"
              ? "completionState"
              : table.tableId === "tbloJ5eN46v1Zx7AG"
                ? "resolverQueue"
                : "resolverSource",
      baseId: table.baseId,
      baseName: table.baseLabel,
      tableId: table.tableId,
      tableName: table.tableLabel,
      primaryFieldId: table.primaryFieldId,
      syncDirection: "readWrite",
      environment: "production",
      configJSON: "{}",
      active: true
    }));

  const costingContracts = [
    {
      contractKey: "input",
      tableName: "costing-input",
      sourceRole: "sparseInputContract",
      engineKey: "costing-engine:ingest",
      stepKey: "costing-engine:step0",
      schema: costingInputSchema
    },
    {
      contractKey: "common",
      tableName: "costing-common",
      sourceRole: "commonDefinitions",
      engineKey: "costing-engine:resolve",
      stepKey: "costing-engine:step1",
      schema: costingCommonSchema
    },
    {
      contractKey: "snapshot",
      tableName: "costing-snapshot",
      sourceRole: "resolvedSnapshotContract",
      engineKey: "costing-engine:snapshot",
      stepKey: "costing-engine:step2",
      schema: costingSnapshotSchema
    }
  ].map(contract => ({
    ...contract,
    table: engineTables.get(contract.tableName),
    sourceKey: `costing-engine:${contract.tableName}`,
    tableConfigKey: `costing-engine:${contract.contractKey}-contract`
  }));

  for (const contract of costingContracts) {
    sourceRecords.push({
      sourceKey: contract.sourceKey,
      systemKey: "costing-engine",
      sourceName: contract.tableName,
      sourceRole: contract.sourceRole,
      baseId: engineCapture.base.baseId,
      baseName: engineCapture.base.baseLabel,
      tableId: contract.table.tableId,
      tableName: contract.table.tableLabel,
      primaryFieldId: contract.table.primaryFieldId,
      primaryFieldName: "$schema",
      syncDirection: "read",
      environment: "production",
      configJSON: JSON.stringify({
        schemaId: contract.schema.$id,
        contractKey: contract.contractKey
      }),
      active: true
    });
  }

  const engineRecords = engineRows.map(row => ({
    engineKey: `task-resolver:${slug(row.Name)}`,
    systemKey: "task-resolver",
    engineName: clean(row.Name),
    engineType: clean(row.Name),
    description: clean(row.Description),
    inputSchemaKey: "eventResolver.context.v1",
    outputSchemaKey: "eventResolver.context.v1",
    eventJSONKeys: clean(row.eventJSONkeys),
    implementationKey: `generic.${slug(row.Name)}.v1`,
    optionsJSON: "{}",
    version: "1.0.0",
    active: true
  }));
  engineRecords.push(
    {
      engineKey: "costing-engine:ingest",
      systemKey: "costing-engine",
      engineName: "Cost Input Ingest",
      engineType: "Event JSON",
      description:
        "Validate and accept sparse, idempotent costing events without treating omitted properties as deletes.",
      inputSchemaKey: "costing-input.schema.json",
      outputSchemaKey: "costing-common.schema.json",
      eventJSONKeys:
        "eventId,operation,projectKey,contract,costEntries,fundingSelections,fundingEvidence,drawRequests,payments",
      implementationKey: "costing.sparse-ingest.v1",
      optionsJSON: JSON.stringify({
        operations: ["upsert", "append", "void"],
        arrayMerge: "stableObjectId"
      }),
      version: "1.0.0",
      active: true
    },
    {
      engineKey: "costing-engine:resolve",
      systemKey: "costing-engine",
      engineName: "Cost Resolution",
      engineType: "Merge",
      description:
        "Resolve current project and task reporting costs while preserving all robo, est, and act observations.",
      inputSchemaKey: "costing-common.schema.json",
      outputSchemaKey: "costing-common.schema.json",
      eventJSONKeys:
        "costEntries,costType,costStatus,amounts,derivation,evidenceIds,fundingSelectionIds",
      implementationKey: "costing.resolve.v1",
      optionsJSON: JSON.stringify({
        precedence: ["act", "est", "robo"],
        deletionMode: "explicitVoidOnly"
      }),
      version: "1.0.0",
      active: true
    },
    {
      engineKey: "costing-engine:snapshot",
      systemKey: "costing-engine",
      engineName: "Cost Snapshot Projection",
      engineType: "Create",
      description:
        "Project the resolved Project-KEY-centered costing snapshot for reporting and downstream reimbursement.",
      inputSchemaKey: "costing-common.schema.json",
      outputSchemaKey: "costing-snapshot.schema.json",
      eventJSONKeys:
        "projectKey,contract,costEntries,fundingSelections,fundingEvidence,drawRequests,payments,reportingSummary",
      implementationKey: "costing.snapshot.v1",
      optionsJSON: JSON.stringify({ pivot: "projectKey" }),
      version: "1.0.0",
      active: true
    }
  );
  const engineKeyByName = new Map(
    engineRecords.map(engine => [engine.engineName, engine.engineKey])
  );

  const stepRecords = [
    ["step0", "Build Context / Update Log", 0, "Update Log", "step1"],
    ["step1", "Resolve Search Inputs", 10, "Search", "step2"],
    ["step2", "Write Resolved Links", 20, "Update", "step3"],
    ["step3", "Find Existing Completion", 30, "Search", "stepX"],
    ["stepX", "Evaluate Conflict Rules", 40, "Compare", "step4"],
    ["step4", "Execute Completion Decision", 50, "Create", ""]
  ].map(([stepCode, stepName, sequence, engineName, nextStep]) =>
    compact({
      stepKey: `task-resolver:${stepCode}`,
      systemKey: "task-resolver",
      stepCode,
      stepName,
      sequence,
      engineKey: engineKeyByName.get(engineName),
      mode: "execute",
      nextStepKey: nextStep ? `task-resolver:${nextStep}` : "",
      onSuccessStepKey: nextStep ? `task-resolver:${nextStep}` : "",
      configSchemaKey:
        stepCode === "step0"
          ? "eventResolver.context.v1"
          : `eventResolver.${stepCode}Config.v1`,
      configJSON: "{}",
      stopOnError: true,
      active: true
    })
  );
  stepRecords.push(
    {
      stepKey: "costing-engine:step0",
      systemKey: "costing-engine",
      stepCode: "step0",
      stepName: "Validate Sparse Cost Input",
      sequence: 0,
      engineKey: "costing-engine:ingest",
      mode: "execute",
      nextStepKey: "costing-engine:step1",
      onSuccessStepKey: "costing-engine:step1",
      configSchemaKey: "costing-input.schema.json",
      configJSON: "{}",
      stopOnError: true,
      active: true
    },
    {
      stepKey: "costing-engine:step1",
      systemKey: "costing-engine",
      stepCode: "step1",
      stepName: "Resolve Current Reporting Cost",
      sequence: 10,
      engineKey: "costing-engine:resolve",
      mode: "execute",
      nextStepKey: "costing-engine:step2",
      onSuccessStepKey: "costing-engine:step2",
      configSchemaKey: "costing-common.schema.json",
      configJSON: JSON.stringify({ precedence: ["act", "est", "robo"] }),
      stopOnError: true,
      active: true
    },
    {
      stepKey: "costing-engine:step2",
      systemKey: "costing-engine",
      stepCode: "step2",
      stepName: "Publish Resolved Cost Snapshot",
      sequence: 20,
      engineKey: "costing-engine:snapshot",
      mode: "execute",
      configSchemaKey: "costing-snapshot.schema.json",
      configJSON: "{}",
      stopOnError: true,
      active: true
    }
  );

  const tableConfigKeyByLabel = new Map();
  const tableConfigRecords = tableConfigRows.map(row => {
    const setupLabel = clean(row.tableResolver);
    const parts = tableConfigParts(setupLabel, engineNames);
    const tableId = extractTableId(row);
    const sourceTable = progressTablesById.get(tableId);
    const tableConfigKey = `task-resolver:${slug(setupLabel)}`;
    tableConfigKeyByLabel.set(setupLabel, tableConfigKey);

    return compact({
      tableConfigKey,
      systemKey: "task-resolver",
      stepKey: parts.stepCode
        ? `task-resolver:${parts.stepCode}`
        : "task-resolver:unassigned",
      engineKey:
        engineKeyByName.get(parts.engineName) ||
        `task-resolver:${slug(parts.engineName)}`,
      setupLabel,
      role: parts.role,
      sourceKey: sourceTable ? sourceKeyForTable(sourceTable) : "",
      baseId: sourceTable?.baseId || progressCapture.base?.baseId,
      tableId,
      tableName: sourceTable?.tableLabel || "",
      searchConfigJSON: JSON.stringify(nonBlankColumns(row, "search.")),
      writeConfigJSON: JSON.stringify(nonBlankColumns(row, "write.")),
      compareConfigJSON: JSON.stringify(nonBlankColumns(row, "compare.")),
      mergeConfigJSON: JSON.stringify(nonBlankColumns(row, "merge.")),
      createConfigJSON: JSON.stringify(nonBlankColumns(row, "create.")),
      optionsJSON: "{}",
      active: true
    });
  });
  for (const contract of costingContracts) {
    const record = {
      tableConfigKey: contract.tableConfigKey,
      systemKey: "costing-engine",
      stepKey: contract.stepKey,
      engineKey: contract.engineKey,
      setupLabel: `Costing ${contract.contractKey} contract`,
      role: contract.sourceRole,
      sourceKey: contract.sourceKey,
      baseId: engineCapture.base.baseId,
      tableId: contract.table.tableId,
      tableName: contract.tableName,
      recordSourcePath: "$schema",
      outputPath:
        contract.contractKey === "snapshot"
          ? "costing.snapshot"
          : `costing.${contract.contractKey}`,
      searchConfigJSON: "{}",
      writeConfigJSON: "{}",
      compareConfigJSON: "{}",
      mergeConfigJSON:
        contract.contractKey === "common"
          ? JSON.stringify({ precedence: ["act", "est", "robo"] })
          : "{}",
      createConfigJSON:
        contract.contractKey === "snapshot"
          ? JSON.stringify({ pivot: "projectKey" })
          : "{}",
      optionsJSON: JSON.stringify({ schemaId: contract.schema.$id }),
      active: true
    };
    tableConfigRecords.push(record);
    tableConfigKeyByLabel.set(record.setupLabel, record.tableConfigKey);
  }

  const tableConfigByKey = new Map(
    tableConfigRecords.map(record => [record.tableConfigKey, record])
  );
  const fieldConfigRecords = [];

  fieldConfigRows.forEach((row, rowIndex) => {
    const setupLabels = splitList(row.tableConfig);
    const targets = setupLabels.length ? setupLabels : [""];

    targets.forEach((setupLabel, targetIndex) => {
      const tableConfigKey =
        tableConfigKeyByLabel.get(setupLabel) ||
        `task-resolver:${slug(setupLabel || "unassigned")}`;
      const tableConfig = tableConfigByKey.get(tableConfigKey);
      const fieldId = clean(row["field.fieldId"]);
      const group = clean(row.group) || "field";
      const writeValue = clean(row["field.writeValue"]);

      fieldConfigRecords.push(
        compact({
          fieldConfigKey:
            `${tableConfigKey}:${slug(group)}:` +
            `${fieldId || rowIndex}:${targetIndex}`,
          systemKey: "task-resolver",
          tableConfigKey,
          sourceKey: tableConfig?.sourceKey || "",
          engineKey: tableConfig?.engineKey || "",
          group,
          semanticName:
            clean(row.eventField) ||
            clean(row["field.fieldLabel"]) ||
            clean(row.keyMap),
          fieldId,
          fieldLabel: clean(row["field.fieldLabel"]),
          fieldType: clean(row["field.fieldType"]),
          jsonPath: clean(row.keyMap),
          eventField: clean(row.eventField),
          writeMode: clean(row["field.writeMode"]),
          writeSource: clean(row["field.writeSource"]),
          writeValueJSON: writeValue
            ? jsonText(writeValue, JSON.stringify(writeValue))
            : "",
          transform: "",
          onMissing: "",
          mergeable: bool(row["field.mergeable"], false),
          required: false,
          configJSON: JSON.stringify({
            completionSearchKey: clean(row["completion.completionSearchKey"]),
            completionKey: clean(row["completion.completionKey"]),
            completedDate: clean(row["completion.completedDate"])
          }),
          active: true
        })
      );
    });
  });

  for (const contract of costingContracts) {
    const contractFields = engineCapture.fields.filter(
      field => field.tableId === contract.table.tableId
    );

    for (const field of contractFields) {
      const jsonPath = `costing.${contract.contractKey}.${field.fieldLabel}`;
      fieldConfigRecords.push({
        fieldConfigKey:
          `${contract.tableConfigKey}:schema-contract:${field.fieldId}`,
        systemKey: "costing-engine",
        tableConfigKey: contract.tableConfigKey,
        sourceKey: contract.sourceKey,
        engineKey: contract.engineKey,
        group: "schema_contract",
        semanticName: field.fieldLabel,
        fieldId: field.fieldId,
        fieldLabel: field.fieldLabel,
        fieldType: field.fieldType,
        jsonPath,
        eventField: field.fieldLabel,
        writeMode: "replace",
        writeSource: "schema",
        transform: "",
        onMissing: "preserve",
        mergeable: false,
        required: field.fieldLabel === "$schema",
        configJSON: JSON.stringify({
          schemaId: contract.schema.$id,
          contractKey: contract.contractKey
        }),
        active: true
      });
    }
  }

  const keyMapRecords = keyMapRows.map(row => {
    const jsonPath = clean(row.json_key);
    const depthValue = Number.parseFloat(clean(row.jsonDepth));
    const valueKind = bool(row.array)
      ? "array"
      : bool(row.object)
        ? "object"
        : "scalar";

    return compact({
      jsonPath,
      systemKey: "task-resolver",
      parentPath: clean(row.parentKey),
      lowestKey: clean(row.lowestKey) || jsonPath.split(".").pop(),
      depth: Number.isFinite(depthValue)
        ? Math.max(0, Math.trunc(depthValue))
        : Math.max(0, jsonPath.split(".").length - 1),
      valueKind,
      rolledUpOn: clean(row.rolledUpOn),
      engineKeys: splitList(row.genericEngine)
        .map(name => engineKeyByName.get(name) || `task-resolver:${slug(name)}`)
        .join(","),
      tableConfigKeys: splitList(row.tableConfigSetups)
        .map(label => tableConfigKeyByLabel.get(label) || label)
        .join(","),
      fieldConfigKeys: clean(row.fieldConfig_eventJSONkey),
      childPaths: clean(row.childKey),
      renderFormula: clean(row.renderFormula),
      ifThenFieldName: clean(row.ifThenFieldName),
      active: true
    });
  });

  for (const contract of costingContracts) {
    const contractFields = engineCapture.fields.filter(
      field => field.tableId === contract.table.tableId
    );

    for (const field of contractFields) {
      const jsonPath = `costing.${contract.contractKey}.${field.fieldLabel}`;
      const pathParts = jsonPath.split(".");
      keyMapRecords.push({
        jsonPath,
        systemKey: "costing-engine",
        parentPath: pathParts.slice(0, -1).join("."),
        lowestKey: pathParts.at(-1),
        depth: pathParts.length - 1,
        valueKind: "scalar",
        rolledUpOn: "schema_contract",
        engineKeys: contract.engineKey,
        tableConfigKeys: contract.tableConfigKey,
        fieldConfigKeys:
          `${contract.tableConfigKey}:schema-contract:${field.fieldId}`,
        description:
          `${contract.contractKey} contract schema leaf stored in ${contract.tableName}.`,
        active: true
      });
    }
  }

  const conflictRuleRecords = conflictRows.map(row => ({
    ruleKey: `task-resolver:${clean(row.key)}`,
    systemKey: "task-resolver",
    engineKey: "task-resolver:compare",
    stepKey: "task-resolver:stepX",
    priority: integer(row.priority, 100),
    stopOnMatch: bool(row.stopOnMatch, false),
    booleanJSON: jsonText(row.boolean, "{}"),
    decision: clean(row.decision),
    actionsJSON: jsonText(row.actions, "[]"),
    reasonCode: clean(row.reasonCode),
    requiredPathsJSON: jsonText(row.requiredColumns, "[]"),
    active: true
  }));

  const systemRecords = [
    {
      systemKey: "task-resolver",
      systemName: "Task Resolver",
      systemVersion: "1.0.0",
      controllerSchema: "eventResolver.engineConfig.v1",
      description:
        "Configuration-driven event resolver using generic search, write, compare, merge, and create engines.",
      owner: "ARCHR",
      status: "Active",
      runtimeMode: "controller",
      defaultSourceBaseId: progressCapture.base?.baseId || "",
      inputSchemaKey: "projectEvent.v2",
      outputSchemaKey: "eventResolver.context.v1",
      settingsJSON: "{}",
      active: true
    },
    {
      systemKey: "progress-task-v2",
      systemName: "Progress Task V2",
      systemVersion: "2.1.0",
      controllerSchema: "progressTask.milestones.v2.1",
      description:
        "Maps normalized project events to milestones, their requirements, and deterministic milestone completions.",
      owner: "ARCHR",
      status: "Active",
      runtimeMode: "controller",
      defaultSourceBaseId: progressCapture.base?.baseId || "",
      inputSchemaKey: "projectEvent.v2",
      outputSchemaKey: "progressTask.completion.v2",
      settingsJSON: JSON.stringify({
        maxAutocompleteLevel: 5,
        milestoneStateModel: "appendOnlyLedger",
        requirementStateModel: "singleRecord",
        requirementSatisfiedStatuses: ["Satisfied", "Waived"]
      }),
      active: true
    },
    {
      systemKey: "costing-engine",
      systemName: "Project Costing Engine",
      systemVersion: "1.0.0",
      controllerSchema: "costing-snapshot.schema.json",
      description:
        "Accepts sparse project cost events, resolves current reporting costs, and publishes Project-KEY-centered snapshots.",
      owner: "ARCHR",
      status: "Active",
      runtimeMode: "controller",
      defaultSourceBaseId: engineCapture.base.baseId,
      inputSchemaKey: "costing-input.schema.json",
      outputSchemaKey: "costing-snapshot.schema.json",
      settingsJSON: JSON.stringify({
        pivot: "projectKey",
        costPrecedence: ["act", "est", "robo"],
        sparseWrites: true,
        deletionMode: "explicitVoidOnly"
      }),
      active: true
    }
  ];

  const releaseRecord = {
    releaseKey: "task-resolver:1.0.0:production",
    systemKey: "task-resolver",
    schemaKey: "eventResolver.engineConfig.v1",
    version: "1.0.0",
    environment: "production",
    status: "Draft",
    generatedAt: new Date().toISOString(),
    sourceBaseId: progressCapture.base?.baseId || "",
    sourceSnapshotAt: new Date().toISOString(),
    configJSON: JSON.stringify({
      schema: "eventResolver.engineConfig.v1",
      systems: ["task-resolver", "progress-task-v2"],
      engineKeys: engineRecords
        .filter(record => record.systemKey === "task-resolver")
        .map(record => record.engineKey),
      stepKeys: stepRecords
        .filter(record => record.systemKey === "task-resolver")
        .map(record => record.stepKey),
      tableConfigKeys: tableConfigRecords
        .filter(record => record.systemKey === "task-resolver")
        .map(record => record.tableConfigKey)
    }),
    releaseNotes: "Generated from repository resolver configuration exports.",
    active: false
  };

  const costingReleaseRecord = {
    releaseKey: "costing-engine:1.0.0:production",
    systemKey: "costing-engine",
    schemaKey: "costing-snapshot.schema.json",
    version: "1.0.0",
    environment: "production",
    status: "Draft",
    generatedAt: new Date().toISOString(),
    sourceBaseId: engineCapture.base.baseId,
    sourceSnapshotAt: new Date().toISOString(),
    configJSON: JSON.stringify({
      schema: "costing-snapshot.schema.json",
      systems: ["costing-engine"],
      engineKeys: engineRecords
        .filter(record => record.systemKey === "costing-engine")
        .map(record => record.engineKey),
      stepKeys: stepRecords
        .filter(record => record.systemKey === "costing-engine")
        .map(record => record.stepKey),
      tableConfigKeys: tableConfigRecords
        .filter(record => record.systemKey === "costing-engine")
        .map(record => record.tableConfigKey)
    }),
    releaseNotes:
      "Generated from the repository costing input, common, and snapshot contracts.",
    active: false
  };

  const progressReleaseRecord = {
    releaseKey: "progress-task-v2:2.1.0:production",
    systemKey: "progress-task-v2",
    schemaKey: "progressTask.milestones.v2.1",
    version: "2.1.0",
    environment: "production",
    status: "Draft",
    generatedAt: new Date().toISOString(),
    sourceBaseId: progressCapture.base?.baseId || "",
    sourceSnapshotAt: new Date().toISOString(),
    configJSON: JSON.stringify({
      schema: "progressTask.milestones.v2.1",
      milestoneTable: "Progress-Tasks",
      milestoneCompletionTable: "Task-Completions",
      requirementTable: "Requirements",
      milestoneRequirementTable: "Milestone-Requirements",
      requirementStateTable: "Requirement-State",
      milestoneCount: taskDrafts.length,
      requirementCount: requirementRecords.length,
      milestoneRequirementMappingCount:
        milestoneRequirementRecords.length
    }),
    releaseNotes:
      "Treats Progress Tasks as milestones and Office subtasks as lighter, mutable-state requirements.",
    active: false
  };

  const costingContractRecords = new Map(
    costingContracts.map(contract => {
      const targetFields = engineCapture.fields.filter(
        field => field.tableId === contract.table.tableId
      );
      return [
        contract.tableName,
        flattenContractRecord(contract.schema, targetFields)
      ];
    })
  );

  const tables = [
    ["Systems", "systemKey", systemRecords],
    ["Sources", "sourceKey", sourceRecords],
    ["Engines", "engineKey", engineRecords],
    ["Engine-Steps", "stepKey", stepRecords],
    ["Table-Configs", "tableConfigKey", tableConfigRecords],
    ["Field-Configs", "fieldConfigKey", fieldConfigRecords],
    ["JSON-Key-Map", "jsonPath", keyMapRecords],
    ["Conflict-Rules", "ruleKey", conflictRuleRecords],
    [
      "Config-Releases",
      "releaseKey",
      [releaseRecord, progressReleaseRecord, costingReleaseRecord]
    ],
    ["Progress-Tasks", "phaseTaskId", taskDrafts.map(task => task.record)],
    ["Task-Dependencies", "dependencyKey", dependencyRecords],
    ["Completion-Rules", "completionRuleKey", completionRuleRecords],
    ["Requirements", "requirementKey", requirementRecords],
    [
      "Milestone-Requirements",
      "mappingKey",
      milestoneRequirementRecords
    ],
    ["Requirement-State", "requirementStateKey", []],
    ["costing-input", "$schema", [costingContractRecords.get("costing-input")]],
    [
      "costing-common",
      "$schema",
      [costingContractRecords.get("costing-common")]
    ],
    [
      "costing-snapshot",
      "$schema",
      [costingContractRecords.get("costing-snapshot")]
    ]
  ].map(([tableName, primaryField, records]) => ({
    tableName,
    tableId: engineTables.get(tableName)?.tableId || "",
    primaryField,
    records: records.map(compact)
  }));

  return {
    schema: "engineBase.seed.v1",
    targetBaseId: engineCapture.base.baseId,
    targetBaseName: engineCapture.base.baseLabel,
    generatedAt: new Date().toISOString(),
    sourceSummary: {
      canonicalTaskRows: currentTasks.length,
      enrichedTaskRows: taskDrafts.filter(
        task => Object.keys(task.source.rich).length > 0
      ).length,
      taskRowsWithSourceRecordId: taskDrafts.filter(
        task => task.record.sourceTaskRecordId
      ).length,
      taskDependencies: dependencyRecords.length,
      completionRules: completionRuleRecords.length,
      officeSubtaskRows: officeSubtaskRows.length,
      requirements: requirementRecords.length,
      milestoneRequirementMappings: milestoneRequirementRecords.length,
      resolverEngines: engineRecords.length,
      tableConfigs: tableConfigRecords.length,
      fieldConfigs: fieldConfigRecords.length,
      jsonKeyPaths: keyMapRecords.length,
      conflictRules: conflictRuleRecords.length,
      costingEngines: engineRecords.filter(
        record => record.systemKey === "costing-engine"
      ).length,
      costingContractFields: costingContracts.reduce(
        (count, contract) =>
          count +
          engineCapture.fields.filter(
            field => field.tableId === contract.table.tableId
          ).length,
        0
      )
    },
    sourceFiles: Object.values(sourcePaths).map(filePath =>
      path.relative(REPO_ROOT, filePath)
    ),
    tables
  };
}

const seed = buildSeed();
fs.writeFileSync(OUTPUT_PATH, `${JSON.stringify(seed, null, 2)}\n`, "utf8");

console.log(`Wrote ${OUTPUT_PATH}`);
console.log(JSON.stringify(seed.sourceSummary, null, 2));
console.log(
  `Total seed records: ${seed.tables.reduce(
    (total, table) => total + table.records.length,
    0
  )}`
);
