<?php
declare(strict_types=1);

/* -----------------------------------------------------------------
 * Minimal genuine .xlsx writer (no extensions required beyond zlib).
 *
 * An .xlsx file is a ZIP container of XML parts. ZipArchive is not
 * enabled on every host, so this builds the ZIP container by hand:
 * local file headers + deflated payloads (gzdeflate) + central
 * directory + end-of-central-directory record.
 *
 * Usage:
 *   archr_xlsx_download('cases_export_2026-08-12.xlsx', ['Case #', 'Name'], [['001234', 'J. Smith']]);
 * ----------------------------------------------------------------- */

/** Build the sheet XML for one worksheet from header + data rows. */
function archr_xlsx_sheet_xml(array $headers, array $rows): string {
    $esc = static fn($v) => htmlspecialchars((string)$v, ENT_XML1 | ENT_QUOTES, 'UTF-8');

    $xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
         . '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
         . '<sheetData>';

    $allRows = array_merge([$headers], $rows);
    foreach ($allRows as $r => $row) {
        $xml .= '<row r="' . ($r + 1) . '">';
        foreach (array_values($row) as $c => $value) {
            // Column letters: A..Z, AA.. (enough for our column counts)
            $col = '';
            $n = $c;
            do {
                $col = chr(65 + ($n % 26)) . $col;
                $n = intdiv($n, 26) - 1;
            } while ($n >= 0);
            $ref = $col . ($r + 1);
            if (is_int($value) || is_float($value)) {
                $xml .= '<c r="' . $ref . '"><v>' . $value . '</v></c>';
            } else {
                $xml .= '<c r="' . $ref . '" t="inlineStr"><is><t xml:space="preserve">'
                      . $esc($value) . '</t></is></c>';
            }
        }
        $xml .= '</row>';
    }
    $xml .= '</sheetData></worksheet>';
    return $xml;
}

/** Assemble a ZIP archive from [name => content] pairs. */
function archr_zip_build(array $files): string {
    $out = '';
    $central = '';
    $offset = 0;
    foreach ($files as $name => $content) {
        $crc = crc32($content);
        $compressed = gzdeflate($content, 6);
        $size = strlen($content);
        $csize = strlen($compressed);
        $nameLen = strlen($name);

        $out .= pack('V', 0x04034b50)          // local file header signature
              . pack('v', 20)                  // version needed
              . pack('v', 0x0800)              // flags: UTF-8 filenames
              . pack('v', 8)                   // method: deflate
              . pack('v', 0) . pack('v', 0)    // mod time/date
              . pack('V', $crc)
              . pack('V', $csize)
              . pack('V', $size)
              . pack('v', $nameLen)
              . pack('v', 0)                   // extra field length
              . $name . $compressed;

        $central .= pack('V', 0x02014b50)      // central directory signature
              . pack('v', 20) . pack('v', 20)  // version made by / needed
              . pack('v', 0x0800)
              . pack('v', 8)
              . pack('v', 0) . pack('v', 0)
              . pack('V', $crc)
              . pack('V', $csize)
              . pack('V', $size)
              . pack('v', $nameLen)
              . pack('v', 0) . pack('v', 0)    // extra, comment
              . pack('v', 0) . pack('v', 0)    // disk start, internal attrs
              . pack('V', 0)                   // external attrs
              . pack('V', $offset)             // local header offset
              . $name;

        $offset += 30 + $nameLen + $csize;
    }
    $out .= $central
          . pack('V', 0x06054b50)              // end of central directory
          . pack('v', 0) . pack('v', 0)
          . pack('v', count($files)) . pack('v', count($files))
          . pack('V', strlen($central))
          . pack('V', $offset)
          . pack('v', 0);
    return $out;
}

/** Stream a one-sheet .xlsx download to the browser. */
function archr_xlsx_download(string $filename, array $headers, array $rows, string $sheetName = 'Cases'): void {
    $sheet = archr_xlsx_sheet_xml($headers, $rows);
    $safeSheet = preg_replace('/[][\\\\\/*?:]/', '', $sheetName) ?: 'Sheet1';

    $files = [
        '[Content_Types].xml' => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            . '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            . '<Default Extension="xml" ContentType="application/xml"/>'
            . '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
            . '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            . '</Types>',
        '_rels/.rels' => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
            . '</Relationships>',
        'xl/workbook.xml' => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
            . 'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
            . '<sheets><sheet name="' . htmlspecialchars($safeSheet, ENT_XML1 | ENT_QUOTES, 'UTF-8')
            . '" sheetId="1" r:id="rId1"/></sheets></workbook>',
        'xl/_rels/workbook.xml.rels' => '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            . '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            . '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
            . '</Relationships>',
        'xl/worksheets/sheet1.xml' => $sheet,
    ];

    $zip = archr_zip_build($files);

    header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    header('Content-Length: ' . strlen($zip));
    header('Cache-Control: no-store');
    echo $zip;
}
