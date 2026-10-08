<!--
  DocsList — the .docs-list section: one row per required document.
  Document on file -> Download button. Missing -> Upload button.
  The expected list lives in src/config/requiredDocuments.js.

  Props:
    documents Array - uploaded docs: [{ key, label, fileName, url }]
                      (empty in the demo — see BACK-END NEED)

  Emits:
    upload (requiredDoc)  - { key, label } of the missing doc
    download (document)   - the on-file doc

  BACK-END NEED: a case_documents table in the dummy base — case_id,
  doc key/category, an Airtable attachment (or URL), uploaded_by,
  uploaded_at. app/ equivalent: lib/case-documents.php + case-documents.php.
-->
<template>
  <section class="panel docs-list" aria-labelledby="docs-list-h">
    <div class="docs-list__head">
      <h2 id="docs-list-h">Documents</h2>
      <span class="docs-list__count">{{ onFileCount }} of {{ required.length }} on file</span>
    </div>
    <ul>
      <li v-for="req in required" :key="req.key" class="doc-row">
        <span class="doc-row__label">
          <strong>{{ req.label }}</strong>
          <span v-if="docFor(req.key)" class="muted"> — {{ docFor(req.key).fileName }}</span>
        </span>
        <span v-if="docFor(req.key)" class="pill pill--green">On file</span>
        <span v-else class="pill pill--amber">Missing</span>
        <button
          v-if="docFor(req.key)"
          type="button"
          class="btn btn--sm doc-row__action"
          @click="$emit('download', docFor(req.key))"
        >
          Download
        </button>
        <button
          v-else
          type="button"
          class="btn btn--sm btn--primary doc-row__action"
          @click="$emit('upload', req)"
        >
          Upload
        </button>
      </li>
    </ul>
  </section>
</template>

<script>
import { REQUIRED_DOCUMENTS } from "../../config/requiredDocuments";

export default {
  name: "DocsList",
  props: {
    documents: { type: Array, default: () => [] }
  },
  data() {
    return { required: REQUIRED_DOCUMENTS };
  },
  computed: {
    onFileCount() {
      return this.required.filter(r => this.docFor(r.key)).length;
    }
  },
  methods: {
    docFor(key) {
      return this.documents.find(d => d.key === key) || null;
    }
  }
};
</script>