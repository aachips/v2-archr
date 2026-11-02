/**********************************************************************
 * Airtable Webhook Emitter
 *
 * Required input variables:
 * - webhookUrl
 * - attachment
 * - recordId
 * - source
 * - projectId
 * - placecodeId
 * - authorId
 * - orgId
 * - docCode
 * - caseId
 * - applicationId
 * - tokens
 *
 * Sends POST body:
 * {
 *   "attachmentUrl": "https://...",
 *   "recordId": "rec...",
 *   "source": "...",
 *   "projectId": "...",
 *   "placecodeId": "...",
 *   "authorId": "...",
 *   "orgId": "...",
 *   "docCode": "...",
 *   "caseId": "...",
 *   "applicationId": "...",
 *   "tokens": "..."
 * }
 **********************************************************************/

const config = input.config();

const {
  webhookUrl,
  attachment,
  recordId,
  source,
  projectId,
  placecodeId,
  authorId,
  orgId,
  docCode,
  caseId,
  applicationId,
  tokens
} = config;





function normalizeValue(value) {
  if (value === null || value === undefined) return "";

  // Airtable lookup / linked-record / rollup style arrays
  if (Array.isArray(value)) {
    return value
      .map(v => {
        if (v === null || v === undefined) return "";

        if (typeof v === "object") {
          return (
            v.id ||
            v.recordId ||
            v.linkedRecordId ||
            v.value ||
            v.name ||
            JSON.stringify(v)
          );
        }

        return String(v);
      })
      .filter(Boolean)
      .join(",");
  }

  if (typeof value === "object") {
    return (
      value.id ||
      value.recordId ||
      value.linkedRecordId ||
      value.value ||
      value.name ||
      JSON.stringify(value)
    );
  }

  return String(value);
}

function getAttachmentUrl(value) {
  if (Array.isArray(value)) {
    const attachmentWithUrl = value.find(item => item && typeof item.url === "string");
    return attachmentWithUrl?.url || "";
  }

  if (value && typeof value === "object") {
    return typeof value.url === "string" ? value.url : "";
  }

  return normalizeValue(value);
}

const payload = {
  attachmentUrl: getAttachmentUrl(attachment),
  recordId: normalizeValue(recordId),
  source: normalizeValue(source),
  projectId: normalizeValue(projectId),
  placecodeId: normalizeValue(placecodeId),
  authorId: normalizeValue(authorId),
  orgId: normalizeValue(orgId),
  docCode: normalizeValue(docCode),
  caseId: normalizeValue(caseId),
  applicationId: normalizeValue(applicationId),
  tokens: normalizeValue(tokens)
};

output.set("webhookPayload", payload);

const response = await fetch(webhookUrl, {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify(payload)
});

const responseText = await response.text();

output.set("webhookStatus", response.status);
output.set("webhookResponse", responseText);

if (!response.ok) {
  throw new Error(`Webhook error ${response.status}: ${responseText}`);
}

let parsedResponse;

try {
  parsedResponse = JSON.parse(responseText);
} catch {
  parsedResponse = responseText;
}

output.set("webhookResult", parsedResponse);
