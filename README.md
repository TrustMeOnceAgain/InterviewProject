# Interview Project
![min iOS version: 15.0](https://img.shields.io/badge/iOS-15.0%2B-blue)
## Description
It is a simple app that uses `SwiftUI`, `Combine` and `CoreData`.  
This project has no business value.  
No external libraries were used.
It is written with `MVVM` in mind where the data operations are performed on the `ViewModel` layer.

## Installation
Simply clone the repo and open the `InterviewProject.xcodeproj` file in Xcode.

## Usage
There is on runnable target: `InterviewProject`.  
Select a device to run at - a specific iOS simulator.  

On the `Posts` screen, there is a possibility to switch between `Local` and `Web` data.  
`Local` is empty at the start but can be populated using the `Save` button on the navigation bar when using view in `Web` mode.  

Unless saved using the `Save` button, everything is stored in memory and will be deleted upon app termination.  
The `Comments` section is only in `Web` mode.

## External links
Markdown documents created using:
- https://dillinger.io/

Badges created using: 
- https://shields.io/

Used API:
- https://jsonplaceholder.typicode.com/
