// ---------------------------------------------------------------------------
// Chrome translations (en / es / uk) — same contract as
// app/lib/language-translations.php: every key has an English string; the
// es/uk slots start EMPTY and render English until a human translator fills
// them in. Add a key here, then use translate(lang, "key") in a component.
//   Rules for translators: never rename keys; keep {placeholders} intact.
// ---------------------------------------------------------------------------

export const LANGUAGES = [
  { code: "en", label: "English" },
  { code: "es", label: "Español" },
  { code: "uk", label: "Українська" }
];

const STRINGS = {
  "brand.tag": { en: "Demo", es: "", uk: "" },
  "nav.search": { en: "Global Case Search", es: "", uk: "" },
  "nav.help": { en: "Help Library", es: "", uk: "" },
  "nav.tasks": { en: "Quick Tasks & Events", es: "", uk: "" },
  "header.searchPlaceholder": { en: "Jump to case #, name, or city…", es: "", uk: "" },
  "header.role": { en: "Role", es: "", uk: "" },
  "header.role.staff": { en: "Staff", es: "", uk: "" },
  "header.role.orgAdmin": { en: "Org Admin", es: "", uk: "" },
  "header.role.superAdmin": { en: "Super Admin", es: "", uk: "" },
  "header.themeToDark": { en: "Switch to dark mode", es: "", uk: "" },
  "header.themeToLight": { en: "Switch to light mode", es: "", uk: "" },
  "header.language": { en: "Language", es: "", uk: "" },
  "header.profile": { en: "Profile Settings", es: "", uk: "" },
  "header.logout": { en: "Log-Out", es: "", uk: "" }
};

// English fallback for empty slots; a missing key renders the key itself so
// gaps are visible instead of silent (mirrors archr_translate() in app/).
export function translate(lang, key) {
  const entry = STRINGS[key];
  if (!entry) return key;
  return entry[lang] || entry.en;
}