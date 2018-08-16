# OpenBDLM

![OpenBDLM](/logo/image.png)

<p align="center">
Structural Health Monitoring using Bayesian Dynamic Linear Model
</p>

OpenBLDM is a Matlab open-source software designed to spread and facilitate the use of Bayesian Dynamic Linear Models for Structural Health Monitoring. OpenBLDM is capable to process simultaneously any time series data recorded on a civil structure (e.g. displacement, elongation, pressure, traffic, temperature, etc...) to monitor and predict its long-term behavior. OpenBLDM includes an anomaly detection tool which allows to detect abnormal structural behavior in a fully probabilistic framework.

## Installation

These instructions will get you a copy of the project up and running on your local machine for direct use, testing and development purposes. 

### Prerequisites

Matlab (version 2016a and above) installed on Mac OSX or Windows

### Installing

1. Extract the ZIP file (or clone the git repository) somewhere you can easily reach it. 
2. Add the `OpenBDLM-master/` folder and all the sub folders to your path in Matlab : e.g. 
    - using the "Set Path" dialog in Matlab, or 
    - by running the `addpath` function from the Matlab command window
 3. Remove from your Matlab path all previously OpenBLDM versions

### Getting started

Enter in the folder OpenBDLM-master, and type `OpenBDLM_main();` in the Matlab command line. The OpenBLDM main menu should appear on the Matlab command window:

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
If you do not see anything except Matlab errors verify your Matlab version, and your Matlab path. Be sure that you run the program from the top-level of OpenBLDM-master folder, not from another folder.

## Running the tests

### Demo

Type `run_DEMO` to run a little demo.

### Version control

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

If you get anything, Matlab errors or something like 

```
     ==> Version control test 1: FAIL
```

it means the program does not run properly on your computer.

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

## License

This project is licensed under the ???? license - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Brian Moore (UD filter implementation)
* Kevin Murphy (initial SKF code)
