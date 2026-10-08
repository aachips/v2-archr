<!--
  DocumentsBucket — browses the document bucket (Dropbox or local tree).
  Calls /app/vue_api/bucket.php through the dev server proxy.
-->
<template>
  <div class="documents-bucket">
    <div class="bucket-header">
      <h2 class="bucket-header__title">
        <i class="fas fa-folder-open"></i> Documents Bucket
      </h2>
      <div class="bucket-header__actions">
        <span v-if="mode === 'dropbox'" class="badge badge--dropbox" title="Connected to Dropbox">
          <i class="fab fa-dropbox"></i> Dropbox
        </span>
        <span v-else class="badge badge--local">Local</span>
        <button type="button" class="btn btn--refresh" @click="load" :disabled="loading" title="Refresh">
          <i :class="loading ? 'fas fa-spinner fa-spin' : 'fas fa-arrows-rotate'"></i>
        </button>
      </div>
    </div>

    <!-- Breadcrumbs -->
    <nav v-if="breadcrumbs.length" class="bucket-breadcrumbs">
      <button class="breadcrumb-item" @click="navigateTo('')">
        <i class="fas fa-house"></i> Root
      </button>
      <span v-for="(crumb, i) in breadcrumbs" :key="i" class="breadcrumb-sep">/</span>
      <button
        v-for="(crumb, i) in breadcrumbs"
        :key="'b-' + i"
        class="breadcrumb-item"
        :class="{ 'breadcrumb-item--current': i === breadcrumbs.length - 1 }"
        @click="navigateTo(crumb.path)"
      >
        {{ crumb.name }}
      </button>
    </nav>

    <!-- Loading / Error -->
    <div v-if="loading && !entries.length" class="bucket-loading">
      <i class="fas fa-spinner fa-spin"></i>
      <p>Loading files…</p>
    </div>

    <div v-else-if="error" class="bucket-error" role="alert">
      <i class="fas fa-triangle-exclamation"></i>
      <p>{{ error }}</p>
      <button type="button" class="btn" @click="load">Retry</button>
    </div>

    <!-- Empty state -->
    <div v-else-if="!entries.length" class="bucket-empty">
      <i class="fas fa-folder-open"></i>
      <p>No files or folders found.</p>
    </div>

    <!-- File/Folder listing -->
    <table v-else class="bucket-table" :class="{ 'bucket-table--grid': viewMode === 'grid' }">
      <thead v-if="viewMode === 'list'">
        <tr>
          <th>Name</th>
          <th>Type</th>
          <th>Size</th>
          <th>Modified</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(entry, idx) in entries" :key="idx" class="bucket-row" :class="'bucket-row--' + entry.tag">
          <td class="bucket-row__name">
            <button v-if="entry.tag === 'folder'" class="bucket-link bucket-link--folder" @click="openFolder(entry)">
              <i class="fas fa-folder"></i> {{ entry.name }}
            </button>
            <span v-else class="bucket-link bucket-link--file">
              <i :class="fileIcon(entry.name)"></i> {{ entry.name }}
            </span>
          </td>
          <td v-if="viewMode === 'list'">{{ entry.tag === 'folder' ? 'Folder' : 'File' }}</td>
          <td v-if="viewMode === 'list'">{{ formatSize(entry.size) }}</td>
          <td v-if="viewMode === 'list'">{{ formatDate(entry.modified) }}</td>
          <td>
            <button v-if="entry.tag === 'file'" class="btn btn--sm" @click="openFile(entry)" title="Download">
              <i class="fas fa-download"></i>
            </button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { getAuthHeaders } from '../services/authService';

const API_URL = '../app/vue_api/bucket.php';

export default {
  name: 'DocumentsBucket',

  data() {
    return {
      entries: [],
      currentPath: '',
      loading: false,
      error: '',
      mode: 'local',
      viewMode: 'list',
    };
  },

  computed: {
    breadcrumbs() {
      if (!this.currentPath) return [];
      const parts = this.currentPath.split('/').filter(Boolean);
      return parts.map((name, i) => ({
        name,
        path: parts.slice(0, i + 1).join('/'),
      }));
    },
  },

  created() {
    this.load();
  },

  methods: {
    async load() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch(API_URL, {
          method: 'POST',
          headers: getAuthHeaders(),
          body: JSON.stringify({ action: 'list', path: this.currentPath }),
        });
        const data = await res.json();
        if (!res.ok || !data.success) {
          this.error = data.error || 'Failed to load bucket';
          this.entries = [];
          return;
        }
        this.entries = data.entries || [];
        this.mode = data.mode || 'local';
      } catch (err) {
        this.error = 'Network error: ' + (err.message || String(err));
        this.entries = [];
      } finally {
        this.loading = false;
      }
    },

    navigateTo(path) {
      this.currentPath = path;
      this.load();
    },

    openFolder(entry) {
      // Dropbox paths start with '/', strip it
      const p = (entry.path || '').replace(/^\//, '');
      this.currentPath = p;
      this.load();
    },

    async openFile(entry) {
      const p = (entry.path || '').replace(/^\//, '');
      try {
        const res = await fetch(API_URL, {
          method: 'POST',
          headers: getAuthHeaders(),
          body: JSON.stringify({ action: 'open', file_path: p }),
        });
        const data = await res.json();
        if (data.success && data.url) {
          window.open(data.url, '_blank');
        }
      } catch {
        // Silent fail
      }
    },

    fileIcon(name) {
      const ext = (name || '').split('.').pop().toLowerCase();
      const map = {
        pdf: 'fas fa-file-pdf',
        doc: 'fas fa-file-word', docx: 'fas fa-file-word',
        xls: 'fas fa-file-excel', xlsx: 'fas fa-file-excel',
        jpg: 'fas fa-file-image', jpeg: 'fas fa-file-image', png: 'fas fa-file-image', gif: 'fas fa-file-image',
        txt: 'fas fa-file-lines',
        html: 'fas fa-file-code',
      };
      return map[ext] || 'fas fa-file';
    },

    formatSize(bytes) {
      if (!bytes) return '—';
      const n = Number(bytes);
      if (n < 1024) return n + ' B';
      if (n < 1024 * 1024) return (n / 1024).toFixed(1) + ' KB';
      return (n / (1024 * 1024)).toFixed(1) + ' MB';
    },

    formatDate(d) {
      if (!d) return '—';
      try {
        return new Date(d).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
      } catch {
        return d;
      }
    },
  },
};
</script>

<style scoped>
.documents-bucket { padding: 1rem; }

.bucket-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem; }
.bucket-header__title { font-size: 1.25rem; font-weight: 600; margin: 0; display: flex; align-items: center; gap: 0.5rem; }
.bucket-header__actions { display: flex; align-items: center; gap: 0.5rem; }

.badge { font-size: 0.75rem; padding: 0.15rem 0.5rem; border-radius: 999px; font-weight: 500; }
.badge--dropbox { background: #0061ff; color: #fff; }
.badge--local { background: #e5e7eb; color: #333; }

.btn--refresh { background: none; border: none; padding: 0.2rem; font-size: 0.85rem; color: #666; cursor: pointer; }
.btn--refresh:hover { color: #333; }
.btn--sm { background: none; border: 1px solid #d1d5db; border-radius: 4px; padding: 0.2rem 0.4rem; font-size: 0.8rem; cursor: pointer; color: #555; }
.btn--sm:hover { background: #f3f4f6; }

.bucket-breadcrumbs { display: flex; align-items: center; gap: 0.25rem; font-size: 0.85rem; margin-bottom: 0.75rem; flex-wrap: wrap; }
.breadcrumb-item { background: none; border: none; padding: 0.15rem 0.3rem; color: #3b82f6; cursor: pointer; font-size: 0.85rem; border-radius: 4px; }
.breadcrumb-item:hover { background: #eff6ff; }
.breadcrumb-item--current { color: #333; font-weight: 600; cursor: default; background: none; }
.breadcrumb-sep { color: #999; }

.bucket-loading, .bucket-empty { text-align: center; padding: 3rem 1rem; color: #888; }
.bucket-loading i, .bucket-empty i { font-size: 2rem; margin-bottom: 0.5rem; display: block; }
.bucket-error { text-align: center; padding: 2rem; color: #b91c1c; background: #fef2f2; border-radius: 8px; }

.bucket-table { width: 100%; border-collapse: collapse; }
.bucket-table th { text-align: left; font-size: 0.8rem; font-weight: 600; color: #555; padding: 0.5rem; border-bottom: 2px solid #e5e7eb; }
.bucket-row td { padding: 0.5rem; border-bottom: 1px solid #f3f4f6; font-size: 0.9rem; }
.bucket-row--folder td { font-weight: 500; }
.bucket-row:hover { background: #f9fafb; }
.bucket-row__name { display: flex; align-items: center; }

.bucket-link { background: none; border: none; cursor: pointer; font-size: 0.9rem; color: #333; text-align: left; padding: 0; }
.bucket-link--folder { color: #2563eb; }
.bucket-link--file { color: #333; }
.bucket-link:hover { text-decoration: underline; }

/* Grid view */
.bucket-table--grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 1rem; border: none; }
.bucket-table--grid thead { display: none; }
.bucket-table--grid tbody { display: contents; }
.bucket-table--grid .bucket-row { display: flex; flex-direction: column; align-items: center; text-align: center; padding: 1rem; border: 1px solid #e5e7eb; border-radius: 8px; background: #fff; }
.bucket-table--grid .bucket-row:hover { background: #f9fafb; }
.bucket-table--grid .bucket-row td:first-child { padding: 0.5rem 0; }
.bucket-table--grid .bucket-row td:not(:first-child) { display: none; }
</style>
