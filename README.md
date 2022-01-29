
<p align="center">
<img src="/logo/image.png" height="150">

<p align="center">
Bayesian Dynamic Linear Model for time-series analysis
</p>

OpenBDLM is a Matlab open-source software designed to use Bayesian Dynamic Linear Models for long-term time series analysis (i.e time step of one hour or higher). OpenBDLM is capable to process simultaneously any time series data to interpret, monitor and predict their long-term behavior. OpenBDLM also includes an anomaly detection tool which allows to detect abnormal behavior in a fully probabilistic framework.

## Installation

These instructions will get you a copy of the project up and running on your local machine for direct use, testing and development purposes. 

### Prerequisites

Matlab (version 2016a or higher) installed on Mac OSX or Windows

### Installing

1. Extract the ZIP file (or clone the git repository) somewhere you can easily reach it. 
2. Add the `OpenBDLM-master/` folder and all the sub folders to your path in Matlab : e.g. 
    - using the "Set Path" dialog in Matlab, or 
    - by running the `addpath` function from the Matlab command window
 3. Remove from your Matlab path all previously OpenBDLM versions

### Getting started

Enter in the folder OpenBDLM-master, and type `OpenBDLM_main();` in the Matlab command line. The OpenBDLM main menu should appear on the Matlab command window:

```
----------------------------------------------------------------------------------------------
     Starting OpenBDLM_V???...
----------------------------------------------------------------------------------------------

            Structural Health Monitoring using Bayesian Dynamic Linear Models

----------------------------------------------------------------------------------------------

- Start a new project: 

     *      Enter a configuration filename 
     0   -> Interactive tool 

- Type D to Delete project(s), V for Version control, Q to Quit.

     choice >> 
```

Type `Q` to Quit the program.

Then, in the Matlab command line, type `run_DEMO` to run a little demo. You should see some messages on the Matlab command window showing that the programs runs properly:

```
     Starting OpenBDLM_V1.7...
     Starting a new project...
     Building model...
     Simulating data...
     Plotting data...
     Saving database (binary format) ...
     Saving database (csv format) ...
     Saving project...
     Printing configuration file...
     Saving database (binary format) ...
     Saving project...
     See you soon !
```
If you do not see anything except Matlab errors verify your Matlab version, and your Matlab path. Be sure that you run the program from the top-level of OpenBDLM-master folder, not from another folder.

## Input

`OpenBDLM_main` accepts three types of input

1. no input (`OpenBDLM_main();`) The program then runs in *interactive mode*, in which online user's interactions from the command line is required to perform the analysis.
2. a configuration file as input, (`OpenBDLM_main('CFG_DEMO.m');`). The configuration file is used to initialize the project, and the program then runs in *interactive mode*. Configuration file must follow a specific format (see OpenBDLM documentation)
3. a cell array as input (`OpenBDLM_main({'''CFG_DEMO.m''','3','1','''Q'''});`). The program runs in *batch mode*, in which pre-loaded commands stored in the input cell-array are sequentially read by the program to perform the analysis.

## Output

`OpenBDLM_main` returns four output:

1. `data` structure which stores the time series data used for the analysis. 
2. `model` 	structure which stores all the information about the model used for the analysis (current model structure and model parameters values)
3. `estimation` structure which stores the computed hidden states estimation using the current data and model.
4.  `misc` structure which stores all the internal variables used by the functions of the program

Type  `[data, model, estimation, misc] = OpenBDLM_main();` to get `data`, `model`, `estimation`, and `misc` as a variable in the Matlab worskpace.

Further details about `data`, `model`, `estimation`, and `misc` can be found in the OpenBDLM documentation.

## Files

`OpenBDLM_main` reads and/or create four types of files:

1. Data file **DATA_*.mat**:  MAT binary file that store the time series data. These files are located in the`data` folder.
3. Configuration file **CFG_*.m** : Matlab script used to initialize and export a project in human readable format. These files are located in the`config_files` folder.
4. Project file **PROJ_*.mat** : MAT binary file that stores a full project for further analysis (basically a project file stores the structure `data`, `model`, `estimation`, and `misc` ). These files are located in the`saved_projects` folder.
5. Log file **LOG_*.txt** : Text file that records information about the analysis. These files are located in the`log_files` folder.


## Version control

For the users, version control tests verifies that the program runs properly on your machine. For development purpose, version control tests verifies that changes you have made are still compatible with the previsous stable OpenBDLM version. To run version control, type `OpenBDLM_main();` in the Matlab command line, and then type `V`.  If program runs properly, you should get in the Matlab command window some messages as shown below:

```
- Version control test #1
 
     Starting OpenBDLM_V1.7...
     Loading configuration file...
     Building model...
     Computing hidden states ...
     Saving project...
     Plotting hidden states estimations ...
     Saving project...
     See you soon !
 
     ==> Version control test 1: PASS
```


## Remarks

Most functions accept numerous options; you can check them out by inspecting their help:

```matlab
help OpenBDLM_main
```

## Built With

* [Matlab](https://www.mathworks.com/products/matlab.html) - Coding
* [matlab2tikz](https://github.com/matlab2tikz/matlab2tikz) - Figure for LaTeX
* [m2html](https://www.artefact.tk/software/matlab/m2html/) - HTML documentation from Matlab

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

To be done...

## Authors

* **James A-Goulet** - *Initial code and development* - [webpage](http://www.polymtl.ca/cgm/jagoulet/Site/Goulet_web_page_MAIN.html)
* **Luong Ha Nguyen** - *Development* - [webpage](http://www.polymtl.ca/cgm/jagoulet/Site/Goulet_web_page_LHNGUYEN.html)
* **Ianis Gaudot** - *Development* - [webpage](http://www.polymtl.ca/cgm/jagoulet/Site/Goulet_web_page_IGAUDOT.html)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

Note that OpenBDLM has been originally developed to use Bayesian Dynamic Linear Models in the context of Structural Health Monitoring, i.e to process simultaneously any time series data recorded on a civil structure (e.g. displacement, elongation, pressure, traffic, temperature, etc...) to monitor and predict its long-term behavior.

## License

This project is licensed under the ???? license - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Brian Moore (UD filter implementation)
* Kevin Murphy (initial SKF code)

