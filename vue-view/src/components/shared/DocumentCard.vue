<template>
  <div class="doc-card">
    <!-- Document row -->
    <div class="doc-card__row" @click="showModal = true">
      <div class="doc-card__icon">
        <i :class="fileIcon"></i>
      </div>
      <div class="doc-card__info">
        <span class="doc-card__name" :title="fileName">{{ fileName }}</span>
        <span class="doc-card__meta">
          <span v-if="docType" class="doc-card__type">{{ docType }}</span>
          <span v-if="fileSize">{{ fileSize }}</span>
          <span v-if="uploadDate">{{ formatDate(uploadDate) }}</span>
        </span>
      </div>
      <div class="doc-card__status">
        <span v-if="redacted" class="doc-card__redacted" title="Redacted — PII hidden">
          <i class="fas fa-eye-slash"></i> Redacted
        </span>
        <span v-else class="doc-card__clean" title="Not redacted">
          <i class="fas fa-eye"></i> Visible
        </span>
      </div>
      <div class="doc-card__actions" @click.stop>
        <button class="btn btn-icon btn-sm" title="Edit metadata" @click="showModal = true">
          <i class="fas fa-edit"></i>
        </button>
        <button class="btn btn-icon btn-sm" title="Download" @click="$emit('download', doc)">
          <i class="fas fa-download"></i>
        </button>
        <button class="btn btn-icon btn-sm" title="Delete" @click="$emit('delete', doc)">
          <i class="fas fa-trash"></i>
        </button>
      </div>
    </div>

    <!-- Edit Document Metadata Modal -->
    <div v-if="showModal" class="doc-modal" @click.self="showModal = false">
      <div class="doc-modal__content">
        <h4>Edit Document Metadata</h4>
        <p class="doc-modal__filename">{{ fileName }}</p>

        <div class="doc-modal__form">
          <div class="doc-modal__field">
            <label>Document Type</label>
            <select v-model="editData.docType">
              <option value="">— Select type —</option>
              <option v-for="t in docTypes" :key="t" :value="t">{{ t }}</option>
            </select>
          </div>

          <div class="doc-modal__field">
            <label>Folder</label>
            <select v-model="editData.folder">
              <option v-for="f in folders" :key="f" :value="f">{{ f }}</option>
            </select>
          </div>

          <div class="doc-modal__field">
            <label>Placecode</label>
            <select v-model="editData.placecode">
              <option value="">— Select placecode —</option>
              <option v-for="p in placecodes" :key="p" :value="p">{{ p }}</option>
            </select>
          </div>

          <div class="doc-modal__field">
            <label>Project</label>
            <select v-model="editData.project">
              <option value="">— Select project —</option>
              <option v-for="proj in projects" :key="proj" :value="proj">{{ proj }}</option>
            </select>
          </div>

          <div class="doc-modal__field doc-modal__field--checkbox">
            <label>
              <input type="checkbox" v-model="editData.redacted" />
              Redact PII (hide personally identifiable information)
            </label>
          </div>

          <div class="doc-modal__field">
            <label>Notes</label>
            <textarea v-model="editData.notes" rows="3" placeholder="Optional metadata notes..."></textarea>
          </div>
        </div>

        <div class="doc-modal__actions">
          <button class="btn btn-sm" @click="cancelEdit">Cancel</button>
          <button class="btn btn-primary btn-sm" @click="saveEdit">Save Changes</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
/**
 * DocumentCard
 *
 * Single document row with edit metadata modal.
 * Consolidated approach — replaces separate folder/type/link/placecode/project widgets.
 *
 * Props:
 *   doc        - Document object { fileName, docType, folder, placecode, project, redacted, notes, fileSize, uploadDate }
 *   docTypes   - Array of allowed document type strings
 *   folders    - Array of folder path strings (from Dropbox root structure)
 *   placecodes - Array of placecode strings
 *   projects   - Array of project name strings
 *
 * Emits:
 *   save, download, delete
 */
export default {
  name: 'DocumentCard',
  props: {
    doc: { type: Object, required: true },
    docTypes: { type: Array, default: function() { return ['Eligibility Verification', 'Contract', 'Site Photo', 'Estimate', 'Scope of Work', 'Invoice', 'Permit', 'Insurance', 'Other']; } },
    folders: { type: Array, default: function() { return ['/organizations/AHFH/cases/247-RIVERSIDE/', '/organizations/AHFH/cases/247-RIVERSIDE/income/', '/organizations/AHFH/cases/247-RIVERSIDE/property/', '/organizations/AHFH/cases/247-RIVERSIDE/financial/']; } },
    placecodes: { type: Array, default: function() { return ['247-RIVERSIDE', '102-MAIN-ST', '55-OAK-AVE']; } },
    projects: { type: Array, default: function() { return ['Roof Repair — Phase 1', 'Plumbing Emergency', 'Foundation Repair']; } }
  },
  data: function() {
    return {
      showModal: false,
      editData: {}
    };
  },
  computed: {
    fileName: function() {
      return this.doc.fileName || this.doc.filename || this.doc.name || 'Untitled';
    },
    docType: function() {
      return this.doc.docType || this.document_type || null;
    },
    fileSize: function() {
      return this.doc.fileSize || this.doc.file_size || null;
    },
    uploadDate: function() {
      return this.doc.uploadDate || this.doc.upload_date || this.doc.created_at || null;
    },
    redacted: function() {
      return !!this.doc.redacted;
    },
    fileIcon: function() {
      var name = this.fileName.toLowerCase();
      if (name.endsWith('.pdf')) return 'fas fa-file-pdf';
      if (name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png')) return 'fas fa-file-image';
      if (name.endsWith('.doc') || name.endsWith('.docx')) return 'fas fa-file-word';
      if (name.endsWith('.xls') || name.endsWith('.xlsx')) return 'fas fa-file-excel';
      return 'fas fa-file';
    }
  },
  methods: {
    formatDate: function(dateStr) {
      if (!dateStr) return '';
      var d = new Date(dateStr);
      if (isNaN(d.getTime())) return dateStr;
      return d.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });
    },
    cancelEdit: function() {
      this.showModal = false;
    },
    saveEdit: function() {
      this.$emit('save', Object.assign({}, this.doc, this.editData));
      this.showModal = false;
    }
  },
  watch: {
    showModal: function(val) {
      if (val) {
        // Clone doc data into editData when modal opens
        this.editData = {
          docType: this.doc.docType || '',
          folder: this.doc.folder || '',
          placecode: this.doc.placecode || '',
          project: this.doc.project || '',
          redacted: !!this.doc.redacted,
          notes: this.doc.notes || ''
        };
      }
    }
  }
};
</script>

<style scoped>
.doc-card__row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 12px;
  border: 1px solid var(--color-border, #e5e7eb);
  border-radius: var(--border-radius, 6px);
  background: var(--bg-surface, #fff);
  cursor: pointer;
  transition: background 0.2s, box-shadow 0.2s;
  margin-bottom: 6px;
}
.doc-card__row:hover {
  background: var(--bg-surface-alt, #f8f9fa);
  box-shadow: var(--shadow-sm, 0 1px 3px rgba(0,0,0,0.06));
}

.doc-card__icon {
  font-size: 1.3rem;
  color: var(--color-text-muted, #6b7280);
  min-width: 28px;
  text-align: center;
}
.doc-card__icon .fa-file-pdf { color: #dc2626; }
.doc-card__icon .fa-file-image { color: #8b5cf6; }
.doc-card__icon .fa-file-word { color: #2563eb; }
.doc-card__icon .fa-file-excel { color: #16a34a; }

.doc-card__info {
  flex: 1;
  min-width: 0;
}
.doc-card__name {
  display: block;
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--color-text, #333);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.doc-card__meta {
  display: flex;
  gap: 10px;
  font-size: 0.75rem;
  color: var(--color-text-muted, #6b7280);
  margin-top: 2px;
}
.doc-card__type {
  background: var(--bg-surface-alt, #f3f4f6);
  padding: 1px 6px;
  border-radius: 3px;
  font-weight: 500;
}

.doc-card__status {
  font-size: 0.75rem;
  font-weight: 600;
  min-width: 80px;
  text-align: center;
}
.doc-card__redacted { color: #d97706; }
.doc-card__clean { color: var(--color-text-muted, #9ca3af); }

.doc-card__actions {
  display: flex;
  gap: 4px;
}

/* Modal */
.doc-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.doc-modal__content {
  background: var(--bg-surface, #fff);
  border-radius: var(--border-radius, 8px);
  padding: 24px;
  width: 90%;
  max-width: 540px;
  max-height: 90vh;
  overflow-y: auto;
}
.doc-modal__content h4 {
  margin: 0 0 4px;
  font-size: 1.1rem;
}
.doc-modal__filename {
  font-family: monospace;
  font-size: 0.8rem;
  color: var(--color-text-muted, #6b7280);
  margin-bottom: 16px;
  word-break: break-all;
}

.doc-modal__form {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 16px;
}

.doc-modal__field label {
  display: block;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text, #333);
  margin-bottom: 4px;
}
.doc-modal__field select,
.doc-modal__field textarea {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  font-size: 0.85rem;
  font-family: inherit;
  background: var(--bg-surface, #fff);
}
.doc-modal__field--checkbox label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 400;
  font-size: 0.85rem;
  color: var(--color-text, #333);
}

.doc-modal__actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  border: 1px solid var(--color-border-strong, #d1d5db);
  border-radius: 4px;
  background: var(--bg-surface, #fff);
  color: var(--color-text, #333);
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
}
.btn:hover { background: var(--bg-surface-alt, #f3f4f6); }
.btn-sm { padding: 4px 10px; font-size: 0.8rem; }
.btn-primary { background: var(--color-primary, #2a5c82); color: #fff; border-color: var(--color-primary, #2a5c82); }
.btn-primary:hover { background: #1e4461; }
.btn-icon { padding: 4px 8px; min-width: 32px; justify-content: center; }
</style>
