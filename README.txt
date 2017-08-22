The main functions of this project are:
	Experiment Setup\src\RunExperiment.m
	DataAnalysis\src\Data Extraction\extractData.m
	DataAnalysis\src\Data Extraction\sampleData.m

Each of these functions are explained in depth in the Guide document available.

There are three ways to execute extractData:

1. extractData(Folder)
	Simply specify the folder
2. extractData(header,ImageData)
  	Input header, and ImageData to analyze them, using only the second half
  	of this function.
3. extractData(Folder,[],0)
  	By default, the function registers the raw images to correct for drift.
  	If you don't wish this to happen, input 0 as the third parameter