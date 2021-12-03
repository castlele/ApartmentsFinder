# ApartsFinder

## Workflow:
1. enter args in cmd line in format
	```afind <file_name:value> <column names:[value]> <arguments> <names of sites:[value]>```

2. SessionService parse erguments into SessionArguments model

3. If everithing allrigh:

	a. create file with given file_name or parse info from it, if it aready exists
	b. parse info from given sites **(or start py script to do so)**:

		1. analize given info
		2. take only needed (depends on given arguments)
		3. write them into the csv file
