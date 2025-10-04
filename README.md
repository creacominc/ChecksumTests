# ChecksumTests

## Overview
The goal of this project is to determine the most efficient way to determine if
a file is unique.  To perform checksums on Terrabytes of data takes time.  Can 
we checksum smaller sizes faster?  What percentage of the files can be found 
to be unique using smaller sizes.

To do this we should first get a set of files from a folder which the user 
specifies.  For each files, we will get the creation and modification dates.  
We will use the earlier of the dates as the creation date since I have seen 
cases where the modification date is earlier than the creation date - possibly 
due to copying of the file.  

For each file, we should get checksums using various amounts of data.  To aovid 
caching giving an impression of preformance, we should perform the checksum for 
a given size across all files in the test set before doing it again for the 
next size.  This should flush the disk cache between file reads if the set 
of files are large enough in total.  

The metrics we need to collect and display would be:

- Total Number of Files;
- Number of files of each type found (photo, audio, video, other);
- Average time taken to checksum the files for each checksum size used;
- Percentage of unique checksums for each size used;


## Requirements
- This app is designed for the Mac
- This is built using xcode and swift.

## Usage
Choose a source folder and checksum sizes, click the Process button and 
examine the results.

## Project Structure
```
ChecksumTests/
├── ChecksumTests/              # Main application source code
│   ├── Assets.xcassets/        # App icons and color assets
│   ├── Tester/                 # Core functionality modules
│   │   └── Tester.swift        # [Describe what this file contains]
│   ├── ChecksumTestsApp.swift  # Main app entry point
│   └── ContentView.swift       # Main UI view
├── ChecksumTestsTests/         # Unit tests
├── ChecksumTestsUITests/       # UI tests
└── [Other project files]
```

### Key Components
- **Tester.swift**: [Describe the main functionality and purpose]
- **ContentView.swift**: [Describe the UI components and structure]
- **ChecksumTestsApp.swift**: [Describe the app initialization]


## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Changelog
[Track changes and versions]

### Version History
- **v0.1.0** - Initial release
  - [List initial features]

---

