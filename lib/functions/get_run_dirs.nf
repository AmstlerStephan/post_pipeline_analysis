def get_run_dirs( input ) {
     def filePattern = ~/run\d{1,2}_{0,1}V{0,1}\d{0,2}$/
     def directory = new File(input)
     def runs = []
     def findFilenameClosure = {
          if (filePattern.matcher(it.name).find()){
               runs.add(it)
          }
     }
     directory.eachFileRecurse(groovy.io.FileType.DIRECTORIES, findFilenameClosure)
     return runs
}