<!--
  HelpLibrary — demo view (page-level, not a library component)
  -------------------------------------------------------------
  Miniature of app/help.php: a categorized doc list + content pane. Content
  comes from src/docs/index.js (copies of the markdown docs the demo needs —
  self-contained on purpose; the full library lives in ../documentation/).

  Rendering is a deliberately tiny markdown subset (headings, bold, inline
  code, lists, paragraphs) so the demo gains no dependencies. Anything
  fancier just displays as plain text.
-->
<template>
  <section class="help">
    <aside class="help__nav">
      <div v-for="(docs, category) in byCategory" :key="category" class="help__cat">
        <h3>{{ category }}</h3>
        <button
          v-for="doc in docs"
          :key="doc.slug"
          type="button"
          :class="['help__link', { active: doc.slug === current.slug }]"
          @click="selected = doc.slug"
        >
          {{ doc.title }}
        </button>
      </div>
    </aside>
    <!-- eslint-disable-next-line vue/no-v-html -->
    <article class="help__content" v-html="rendered"></article>
  </section>
</template>

<script>
import { DOC_LIBRARY } from "../docs";

function escapeHtml(s) {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// Tiny markdown subset: #/##/### headings, **bold**, `code`, "- " list items,
// numbered lists, paragraphs. Input is escaped first, so no raw HTML.
function renderMarkdown(md) {
  const lines = escapeHtml(md).split("\n");
  const html = [];
  let inList = false;
  const closeList = () => {
    if (inList) { html.push("</ul>"); inList = false; }
  };
  const inline = s =>
    s
      .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
      .replace(/`([^`]+)`/g, "<code>$1</code>");
  for (const line of lines) {
    const t = line.trim();
    if (!t) { closeList(); continue; }
    const heading = /^(#{1,3})\s+(.*)$/.exec(t);
    if (heading) {
      closeList();
      const level = heading[1].length + 1; // # -> h2, ## -> h3, ### -> h4
      html.push(`<h${level}>${inline(heading[2])}</h${level}>`);
      continue;
    }
    const bullet = /^(?:-|\d+\.)\s+(.*)$/.exec(t);
    if (bullet) {
      if (!inList) { html.push("<ul>"); inList = true; }
      html.push(`<li>${inline(bullet[1])}</li>`);
      continue;
    }
    closeList();
    html.push(`<p>${inline(t)}</p>`);
  }
  closeList();
  return html.join("\n");
}

export default {
  name: "HelpLibrary",
  data() {
    return { selected: DOC_LIBRARY[0] ? DOC_LIBRARY[0].slug : "" };
  },
  computed: {
    byCategory() {
      const groups = {};
      for (const doc of DOC_LIBRARY) {
        (groups[doc.category] = groups[doc.category] || []).push(doc);
      }
      return groups;
    },
    current() {
      return DOC_LIBRARY.find(d => d.slug === this.selected) || DOC_LIBRARY[0];
    },
    rendered() {
      return this.current ? renderMarkdown(this.current.body) : "";
    }
  }
};
</script>

<style scoped>
.help {
  display: grid;
  grid-template-columns: 15rem 1fr;
  gap: 1.5rem;
  align-items: start;
}

.help__cat h3 {
  margin: 0.75rem 0 0.25rem;
  font-size: 0.8rem;
  text-transform: uppercase;
  color: #6b7280;
}

.help__link {
  display: block;
  width: 100%;
  padding: 0.3rem 0.5rem;
  border: none;
  border-radius: 4px;
  background: none;
  font: inherit;
  text-align: left;
  cursor: pointer;
}

.help__link:hover { background: #f3f4f6; }
.help__link.active { background: #e0e7ff; font-weight: 600; }

.help__content {
  max-width: 46rem;
  line-height: 1.6;
}

.help__content code {
  background: #f3f4f6;
  padding: 0.05rem 0.3rem;
  border-radius: 3px;
}
</style>
