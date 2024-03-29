<?php

define('SOURCE_LANG', $argv[1]);
define('DEST_LANG', $argv[2]);
define('API_KEY', $argv[3]);

if(empty(SOURCE_LANG))
{
    echo "source_lang required";
    die;
}

if(empty(DEST_LANG))
{
    echo "dest_lang required";
    die;
}

if(empty(API_KEY))
{
    echo "api_key required";
    die;
}

function processArray(&$item, $key) {
    var_dump('before translation: ' . $item);
    $item = translate($item);
    var_dump('after translation: ' . $item);
}

function translate($text) {
    // get cURL resource
    $ch = curl_init();

    // set url
    curl_setopt($ch, CURLOPT_URL, 'https://www.googleapis.com/language/translate/v2?key=' . API_KEY . '&source=' . SOURCE_LANG . '&target=' . DEST_LANG . '&q=' . urlencode($text) . '&format=text');

    // set method
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'GET');

    // return the transfer as a string
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

    // send the request and save response to $response
    $response = curl_exec($ch);

    // stop if fails
    if (!$response) {
      return false;
    }

    $data = json_decode($response);

    if(!$data) {
        return false;
    }

    // close curl resource to free up system resources 
    curl_close($ch);

    return $data->data->translations[0]->translatedText;
}

$dirs = array_filter(glob('*'), 'is_dir');

foreach($dirs as $dir) {
    if(strpos($dir, 'chapter-') === 0) {
        $chapter_number = explode('-', $dir)[1];

        print './' . $dir . '/' . $chapter_number . "-combined.json\n";

        $source_file = file_get_contents('./' . $dir . '/' . $chapter_number . '-combined.json');

        $source_data = json_decode($source_file, true);

        if(empty($source_data))
        {
            echo "source_data not found";
            die;
        }

        array_walk_recursive($source_data, 'processArray');

        file_put_contents('./' . $dir . '/' . $chapter_number . '-' . DEST_LANG . '-combined.json', json_encode($source_data, JSON_PRETTY_PRINT));
    }
}