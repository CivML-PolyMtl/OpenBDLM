# OpenBDLM

Structural Health Monitoring using Bayesian Dynamic Linear Models


## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

Matlab version (>2016a) on Mac or Windows


```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### DEMO

This gives a first overview of what the program does.

```
run_DEMO
```

### VERSION CONTROL

For user purpose, version control tests verifies that the program gives the right results on your machine.
For development purpose, version control tests verifies that change are compatible with previsous stable version.

In Matlab command line type,

```
[data, model, estimation, misc] = OpenBDLM()
```

and then type V in the Matlab command line.

```
V
```

You should get semething like that if the program works well.

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

## Deployment

Add additional notes about how to deploy this on a live system

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