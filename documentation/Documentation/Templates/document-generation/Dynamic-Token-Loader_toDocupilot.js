/**********************************************************************
 * Airtable Dynamic Token Loader → Docupilot
 *
 * Required Airtable Automation inputs:
 * - airtablePAT
 * - triggerRecordId
 * - configJson
 *
 * Optional input:
 * - defaultDownloadMode
 *
 * Config JSON shape:
 * {
 *   "dpEndpointUrl": "https://api.docupilot.app/documents/create/7615ee2a/7b5b335d/",
 *   "downloadMode": "true",
 *   "outputNameTemplate": "Document - {{docHomeFullName}}",
 *   "tokens": [
 *     {
 *       "tokenName": "{{docHomeFullName}}",
 *       "valueFieldUrl": "https://airtable.com/appXXX/tblXXX/viwXXX/fldXXX",
 *       "valueType": "string"
 *     },
 *     {
 *       "tokenName": "{{docZeroSignature}}",
 *       "valueFieldUrl": "https://airtable.com/appXXX/tblXXX/viwXXX/fldXXX",
 *       "valueType": "imageUrl"
 *     }
 *   ]
 * }
 *
 * Supported valueType:
 * - imageUrl
 * - string
 * - num
 * - currency
 * - int
 * - richText
 **********************************************************************/

const inputConfig = input.config();

const {
  airtablePAT,
  triggerRecordId,
  configJson,
  defaultDownloadMode = "true"
} = inputConfig;
console.log(inputConfig)
// -------------------------------------------------------------------
// Basic validation
// -------------------------------------------------------------------

function isBlankInput(value) {
  if (value === undefined || value === null) return true;
  if (typeof value === "string" && value.trim() === "") return true;
  if (Array.isArray(value) && value.length === 0) return true;
  return false;
}

if (isBlankInput(airtablePAT)) {
  throw new Error("Missing required input: airtablePAT");
}

if (isBlankInput(triggerRecordId)) {
  throw new Error("Missing required input: triggerRecordId");
}

if (isBlankInput(configJson)) {
  throw new Error("Missing required input: configJson");
}

// -------------------------------------------------------------------
// Parsing helpers
// -------------------------------------------------------------------

function parseMaybeJson(value, label = "JSON") {
  if (value === null || value === undefined || value === "") {
    throw new Error(`Missing ${label}.`);
  }

  // Airtable lookup-style array:
  // [{ linkedRecordId: "rec...", value: "{\"dpEndpointUrl\":\"...\"}" }]
  if (Array.isArray(value)) {
    if (value.length === 0) {
      throw new Error(`${label} is an empty array.`);
    }

    if (
      value.length === 1 &&
      value[0] &&
      typeof value[0] === "object" &&
      "value" in value[0]
    ) {
      return parseMaybeJson(value[0].value, `${label}[0].value`);
    }

    if (value.length === 1) {
      return parseMaybeJson(value[0], `${label}[0]`);
    }

    const firstWithValue = value.find(v =>
      v &&
      typeof v === "object" &&
      "value" in v
    );

    if (firstWithValue) {
      return parseMaybeJson(firstWithValue.value, `${label}[first.value]`);
    }

    throw new Error(`${label} is an array, but no usable JSON value was found.`);
  }

  // Airtable lookup-style object:
  // { linkedRecordId: "rec...", value: "{\"dpEndpointUrl\":\"...\"}" }
  if (
    value &&
    typeof value === "object" &&
    "value" in value &&
    !("dpEndpointUrl" in value) &&
    !("dpWorkspaceId" in value)
  ) {
    return parseMaybeJson(value.value, `${label}.value`);
  }

  // Already parsed object
  if (value && typeof value === "object") {
    return value;
  }

  let str = String(value).trim();

  // Handles values pasted like:
  // input: {"dpEndpointUrl":"...", ...}
  str = str.replace(/^input\s*:\s*/i, "");

  // Handles accidental code fences
  str = str
    .replace(/^```(?:json|js)?\s*/i, "")
    .replace(/```$/i, "")
    .trim();

  let parsed;

  try {
    parsed = JSON.parse(str);
  } catch (err) {
    throw new Error(
      `Could not parse ${label}: ${err.message}. Raw value starts: ${str.slice(0, 500)}`
    );
  }

  // Handles double-encoded JSON strings
  if (typeof parsed === "string") {
    return parseMaybeJson(parsed, `${label} double-encoded`);
  }

  return parsed;
}

function unwrapDocConfig(value) {
  let obj = parseMaybeJson(value, "configJson");

  for (let i = 0; i < 10; i++) {
    const isValidEndpointConfig =
      obj &&
      typeof obj === "object" &&
      obj.dpEndpointUrl &&
      Array.isArray(obj.tokens);

    const isValidLegacyConfig =
      obj &&
      typeof obj === "object" &&
      obj.dpWorkspaceId &&
      obj.dpTemplateId &&
      Array.isArray(obj.tokens);

    if (isValidEndpointConfig || isValidLegacyConfig) {
      return obj;
    }

    if (Array.isArray(obj)) {
      if (obj.length === 1) {
        obj = parseMaybeJson(obj[0], "single-item config array");
        continue;
      }

      const firstWithValue = obj.find(v =>
        v &&
        typeof v === "object" &&
        "value" in v
      );

      if (firstWithValue) {
        obj = parseMaybeJson(firstWithValue.value, "config lookup value");
        continue;
      }
    }

    if (
      obj &&
      typeof obj === "object" &&
      "value" in obj &&
      !obj.dpEndpointUrl &&
      !obj.dpWorkspaceId
    ) {
      obj = parseMaybeJson(obj.value, "config.value");
      continue;
    }

    const wrapperKeys = [
      "input",
      "config",
      "docConfig",
      "docConfigJson",
      "payload",
      "payloadJson",
      "data",
      "fields"
    ];

    const foundWrapperKey = wrapperKeys.find(key =>
      obj &&
      typeof obj === "object" &&
      obj[key] !== undefined &&
      obj[key] !== null &&
      String(obj[key]).trim?.() !== ""
    );

    if (foundWrapperKey) {
      obj = parseMaybeJson(
        obj[foundWrapperKey],
        `nested config at "${foundWrapperKey}"`
      );
      continue;
    }

    break;
  }

  return obj;
}

function cleanTokenName(tokenName) {
  return String(tokenName || "")
    .trim()
    .replace(/^\{\{\s*/, "")
    .replace(/\s*\}\}$/, "")
    .trim();
}

function parseAirtableFieldUrl(url) {
  const str = String(url || "").trim();

  const appMatch = str.match(/\/(app[a-zA-Z0-9]+)(?:\/|$)/);
  const tblMatch = str.match(/\/(tbl[a-zA-Z0-9]+)(?:\/|$)/);
  const viwMatch = str.match(/\/(viw[a-zA-Z0-9]+)(?:\/|$)/);
  const fldMatch = str.match(/\/(fld[a-zA-Z0-9]+)(?:[/?#]|$)/);

  if (!appMatch || !tblMatch || !fldMatch) {
    throw new Error(`Could not parse Airtable field URL: ${str}`);
  }

  return {
    baseId: appMatch[1],
    tableId: tblMatch[1],
    viewId: viwMatch ? viwMatch[1] : "",
    fieldId: fldMatch[1]
  };
}

function encodeParams(params) {
  const usp = new URLSearchParams();

  for (const [key, value] of Object.entries(params)) {
    if (value !== undefined && value !== null && String(value).trim() !== "") {
      usp.append(key, value);
    }
  }

  return usp.toString();
}

// -------------------------------------------------------------------
// Airtable fetch helpers
// -------------------------------------------------------------------

async function airtableFetchJson(url) {
  const res = await fetch(url, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${airtablePAT}`,
      "Content-Type": "application/json"
    }
  });

  const text = await res.text();

  if (!res.ok) {
    throw new Error(`Airtable API error ${res.status}: ${text}`);
  }

  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`Airtable returned non-JSON response: ${text}`);
  }
}

const recordCache = new Map();

async function getRemoteRecord(baseId, tableId, recordId) {
  const cacheKey = `${baseId}::${tableId}::${recordId}`;

  if (recordCache.has(cacheKey)) {
    return recordCache.get(cacheKey);
  }

  const query = encodeParams({
    returnFieldsByFieldId: "true"
  });

  const url = `https://api.airtable.com/v0/${baseId}/${tableId}/${recordId}?${query}`;

  const record = await airtableFetchJson(url);
  recordCache.set(cacheKey, record);

  return record;
}

// -------------------------------------------------------------------
// Value normalization helpers
// -------------------------------------------------------------------

function isAttachmentArray(value) {
  return Array.isArray(value) && value.some(item =>
    item &&
    typeof item === "object" &&
    (
      "url" in item ||
      "filename" in item ||
      "type" in item ||
      "size" in item
    )
  );
}

function toPlainString(value) {
  if (value === null || value === undefined) return "";

  if (typeof value === "string") return value;

  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }

  if (isAttachmentArray(value)) {
    return value
      .map(att => att.url || att.filename || "")
      .filter(Boolean)
      .join(", ");
  }

  if (Array.isArray(value)) {
    return value
      .map(v => {
        if (v === null || v === undefined) return "";

        if (typeof v === "object") {
          return (
            v.name ||
            v.email ||
            v.filename ||
            v.id ||
            JSON.stringify(v)
          );
        }

        return String(v);
      })
      .filter(Boolean)
      .join(", ");
  }

  if (typeof value === "object") {
    return (
      value.name ||
      value.email ||
      value.filename ||
      value.id ||
      JSON.stringify(value)
    );
  }

  return String(value);
}

function parseNumber(value) {
  if (value === null || value === undefined || value === "") return null;

  if (typeof value === "number") {
    return Number.isFinite(value) ? value : null;
  }

  const cleaned = String(value)
    .replace(/[$,\s]/g, "")
    .replace(/[^\d.-]/g, "");

  if (!cleaned) return null;

  const num = Number(cleaned);

  return Number.isFinite(num) ? num : null;
}

function formatNum(value) {
  const num = parseNumber(value);
  if (num === null) return "";
  return String(num);
}

function formatInt(value) {
  const num = parseNumber(value);
  if (num === null) return "";
  return String(Math.round(num));
}

function formatCurrency(value) {
  const num = parseNumber(value);
  if (num === null) return "";

  return num.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

function getFirstAttachmentUrl(value, preferImage = false) {
  if (!isAttachmentArray(value)) {
    return toPlainString(value);
  }

  const attachments = value;

  if (preferImage) {
    const image = attachments.find(att =>
      String(att.type || "").startsWith("image/")
    );

    if (image?.url) {
      return image.url;
    }
  }

  return attachments[0]?.url || "";
}

function formatRichText(value) {
  if (value === null || value === undefined) return "";

  if (typeof value === "string") {
    return value;
  }

  if (isAttachmentArray(value)) {
    return value
      .map(att => att.url || att.filename || "")
      .filter(Boolean)
      .join("\n");
  }

  if (Array.isArray(value)) {
    return value
      .map(v => toPlainString(v))
      .filter(Boolean)
      .join("\n");
  }

  return toPlainString(value);
}

function normalizeValueForDocupilot(value, token = {}) {
  const valueType = String(token.valueType || "string").trim();

  switch (valueType) {
    case "imageUrl":
      return getFirstAttachmentUrl(value, true);

    case "string":
      return toPlainString(value);

    case "num":
      return formatNum(value);

    case "currency":
      return formatCurrency(value);

    case "int":
      return formatInt(value);

    case "richText":
      return formatRichText(value);

    default:
      throw new Error(
        `Unsupported valueType "${valueType}" for token "${token.tokenName || ""}". ` +
        `Allowed values: imageUrl, string, num, currency, int, richText`
      );
  }
}

// -------------------------------------------------------------------
// Docupilot helpers
// -------------------------------------------------------------------

function buildDocupilotEndpoint(docConfig, downloadMode) {
  let url = String(docConfig.dpEndpointUrl || "").trim();

  if (!url) {
    throw new Error("Config must include dpEndpointUrl.");
  }

  if (
    downloadMode !== undefined &&
    downloadMode !== null &&
    String(downloadMode).trim() !== "" &&
    !/[?&]download=/.test(url)
  ) {
    url += url.includes("?") ? "&" : "?";
    url += `download=${encodeURIComponent(String(downloadMode))}`;
  }

  return url;
}

function buildOutputName(template, data, fallback) {
  if (!template) return fallback;

  return String(template).replace(/\{\{\s*([^}]+?)\s*\}\}/g, (_, key) => {
    const cleanKey = String(key).trim();
    return data[cleanKey] ?? "";
  });
}

// -------------------------------------------------------------------
// Main
// -------------------------------------------------------------------

const docConfig = unwrapDocConfig(configJson);

if (!docConfig || typeof docConfig !== "object") {
  throw new Error(
    `Config JSON must be an object. Parsed config was: ${JSON.stringify(docConfig).slice(0, 1500)}`
  );
}

if (!docConfig.dpEndpointUrl && (!docConfig.dpWorkspaceId || !docConfig.dpTemplateId)) {
  throw new Error(
    `Config JSON must include dpEndpointUrl OR both dpWorkspaceId and dpTemplateId. Parsed config was: ${JSON.stringify(docConfig).slice(0, 1500)}`
  );
}

if (!Array.isArray(docConfig.tokens)) {
  throw new Error(
    `Config JSON missing tokens array. Parsed config was: ${JSON.stringify(docConfig).slice(0, 1500)}`
  );
}

const data = {};
const debug = [];

for (const token of docConfig.tokens) {
  const tokenKey = cleanTokenName(token.tokenName);

  if (!tokenKey) {
    debug.push({
      status: "skipped",
      reason: "Missing tokenName",
      token
    });
    continue;
  }

  if (!token.valueFieldUrl) {
    data[tokenKey] = "";

    debug.push({
      tokenKey,
      status: "blank",
      reason: "Missing valueFieldUrl"
    });

    continue;
  }

  const source = parseAirtableFieldUrl(token.valueFieldUrl);

  /**
   * Default:
   * - Use global triggerRecordId as the source record ID.
   *
   * Optional per-token override:
   * {
   *   "tokenName": "{{example}}",
   *   "valueFieldUrl": "...",
   *   "valueType": "string",
   *   "recordId": "recXXXXXXXXXXXXXX"
   * }
   */
  const sourceRecordId = token.recordId || triggerRecordId;

  const sourceRecord = await getRemoteRecord(
    source.baseId,
    source.tableId,
    sourceRecordId
  );

  const rawValue = sourceRecord.fields?.[source.fieldId];
  const normalizedValue = normalizeValueForDocupilot(rawValue, token);

  data[tokenKey] = normalizedValue;

  debug.push({
    tokenKey,
    valueType: token.valueType || "string",
    sourceBaseId: source.baseId,
    sourceTableId: source.tableId,
    sourceFieldId: source.fieldId,
    sourceRecordId,
    rawValueType: Array.isArray(rawValue) ? "array" : typeof rawValue,
    normalizedValuePreview:
      typeof normalizedValue === "string"
        ? normalizedValue.slice(0, 250)
        : normalizedValue
  });
}

// Optional config value:
// "outputNameTemplate": "Document - {{docHomeFullName}}"
const outputName = buildOutputName(
  docConfig.outputNameTemplate,
  data,
  `Docupilot_${triggerRecordId}`
);

const downloadMode =
  docConfig.downloadMode !== undefined
    ? docConfig.downloadMode
    : defaultDownloadMode;

const docupilotUrl = buildDocupilotEndpoint(docConfig, downloadMode);

/**
 * Docupilot classic create endpoint expects token data as the root body:
 *
 * {
 *   "docHomeFullName": "Jane Doe",
 *   "docZeroSignedDate": "2026-06-12",
 *   "docZeroSignature": "https://v5.airtableusercontent.com/..."
 * }
 */
const docupilotPayload = {
  ...data,
  outputName
};

// Debug before Docupilot fetch
output.set("docConfig", docConfig);
output.set("docupilotUrlBeforeFetch", docupilotUrl);
output.set("docupilotPayloadBeforeFetch", docupilotPayload);
output.set("dataBeforeFetch", data);
output.set("debugBeforeFetch", debug);

const docupilotBaseUrl = docupilotUrl.split("?")[0];
const docupilotOrigin = new URL(docupilotBaseUrl).origin;

const docupilotRes = await fetch(docupilotUrl, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "Accept": "application/json",

    // Docupilot/Django CSRF strict referer check wants same-origin context.
    "Origin": docupilotOrigin,
    "Referer": docupilotBaseUrl
  },

  // Some fetch implementations use this instead of a raw Referer header.
  referrer: docupilotBaseUrl,
  referrerPolicy: "strict-origin-when-cross-origin",

  body: JSON.stringify(docupilotPayload)
});

const docupilotText = await docupilotRes.text();

if (!docupilotRes.ok) {
  output.set("docupilotUrl", docupilotUrl);
  output.set("data", data);
  output.set("debug", debug);
  output.set("docupilotPayload", docupilotPayload);
  output.set("docupilotResponseStatus", docupilotRes.status);
  output.set("docupilotResponseText", docupilotText);

  throw new Error(`Docupilot error ${docupilotRes.status}: ${docupilotText}`);
}

let docupilotResult;

try {
  docupilotResult = JSON.parse(docupilotText);
} catch {
  docupilotResult = docupilotText;
}

output.set("docupilotUrl", docupilotUrl);
output.set("outputName", outputName);
output.set("data", data);
output.set("debug", debug);
output.set("docupilotPayload", docupilotPayload);
output.set("docupilotResult", docupilotResult);