# OpenBDLM

![OpenBDLM](/logo/image.png)


 Structural Health Monitoring using Bayesian Dynamic Linear Models

<p style="text-align: center;"> Structural Health Monitoring using Bayesian Dynamic Linear Models


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Matlab version (>2016a) on Mac or Windows

### Installing

From the Github repository clone or download the program.

If downloading the program, you have to unzip the folder.

Put OpenBDLM-master and all the subdirectory in your Matlab path.
Remove from path all previously OpenBDLM version.
Enter in OpenBDLM-master, and type in the Matlab command line 

```
OpenBLDM_main
```

You should see something like that if the programs works well:

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

Type Q to Quit the program.


Then, in the Matlab command line, type:

```
run_DEMO
```

to run a little demo.

You should get semething like that if the program works well:

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

## Running the tests

### Version control

For the users, version control tests verifies that the program gives the right results on your machine.
For development purpose, version control tests verifies that change are compatible with previsous stable version.

In Matlab command line type,

```
[data, model, estimation, misc] = OpenBDLM()
```

and then type V in the Matlab command line.

You should get semething like that if the program works well:

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

If you get anything or something like that

```
     ==> Version control test 1: FAIL
```

It means something is wrong.

## Built With

* [Matlab](https://www.mathworks.com/products/matlab.html) - Coding
* [matlab2tikz](https://github.com/matlab2tikz/matlab2tikz) - Figure for LaTeX
* [m2html](https://www.artefact.tk/software/matlab/m2html/) - HTML documentation from Matlab

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

TBD

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