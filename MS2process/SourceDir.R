sourceDir<-function(path,trace=TRUE,...){
	print("MS2-classes.R :\n")
	source("./Documents/Alexis/CopieMS2Process/MS2-classes.R")
	for (nm in list.files(path, pattern = "[.][RrSsQq]$")) {
	    if(trace) cat(nm,":\n")
		source(file.path(path, nm), ...)
	}
}