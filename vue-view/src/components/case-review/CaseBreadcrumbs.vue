<!--
  CaseBreadcrumbs — back-navigation for the review page.
  Today: a single "back to list" button (parent owns view state). When the
  demo adopts vue-router (see vue-view README follow-ups) this becomes a real
  trail: Global Case Search > Case Review.
-->
<template>
  <nav class="breadcrumbs" aria-label="Breadcrumb">
    <button type="button" class="breadcrumbs__link" @click="$emit('back')">
      &larr; Back to case list
    </button>
  </nav>
</template>

<script>
export default {
  name: "CaseBreadcrumbs"
};
</script>