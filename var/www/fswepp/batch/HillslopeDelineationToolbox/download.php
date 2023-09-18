<?php
// Define a mapping of meaningful names to file paths
$files = [
    'arcgis_v10-3' => 'toolbox/Hillslope_Delineation_Tools_v10-3(ism).tbx',
    'arcgis_v10-0' => 'toolbox/Hillslope_Delineation_Tools_v10.0.tbx',
    'arcgis_v9-3'  => 'toolbox/HillslopeDelineationTools9.3.tbx'
];

// Check if the 'file' GET parameter is set and exists in our mapping
if (isset($_GET['file']) && isset($files[$_GET['file']])) {
    $file = $files[$_GET['file']];

    if (file_exists($file)) {
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="'.basename($file).'"');
        header('Expires: 0');
        header('Cache-Control: must-revalidate');
        header('Pragma: public');
        header('Content-Length: ' . filesize($file));
        readfile($file);
        exit;
    }
}

// If file not found or some other error
header("HTTP/1.0 404 Not Found");
echo "File not found!";
?>
