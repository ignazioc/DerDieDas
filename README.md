# DerDieDas
![](documentation/dictcc_logo.png)

Alfred workflow for easily translate and get the gender of the german words

This workflow is based on the dict.cc dictionary.
Accordingly to the "Terms of Use" of dict.cc, this repository doesn't contain the dictionary data, but you can request it for free visiting this page:
[link](https://www1.dict.cc/translation_file_request.php?l=e)

## How to use

Once you have downloaded the dictionary, rename it as `full_dictionary.txt` and copy it into the workflow folder.

To find the exact folder, click on the small icon on the detail of the workflow.

![](documentation/open_path.png)

The workflow shows you an error in case the dictionary file is not found.

![](documentation/missing_dict.png)

Because of the nature of the workflow, the script need to create some indexes.
This must be done only once.

![](documentation/indexes.png)


Now eveything is setup and you can do your searches

![](documentation/results.png)



*Note:* 
Thanks to deanishe from the Alfred forum, who helped me understand the hidden mystery of NSTask and _unicode normalization_