# Shadowed-Rice-Fading-Matlab
The shadowed Rician fading model implemented in Matlab and was created using Matlab 2018a.
Plots the theoretical and simulated, envelope and phase porbability density functions (PDFs).

For more information this model please refer to Browning's paper (me):
"The Rician Complex Envelope under Line of Sight Shadowing".

Run main.m to start the GUI if Matlab is already installed.
Alternatively if Matlab isn't installed, can run the installer from the build folder, which requires an internet connection to download the required files.

The input K accepts values in the range 0.001 to 50.
The input m accepts values in the range 0.001 to 50.
The input \hat{r} accepts values in the range 0.5 to 2.5.
The input \phi accepts values in the range -pi to pi.

When running the program the intial window appears:

![ScreenShot](https://raw.github.com/Jonathan-Browning/Shadowed-Rician-Fading-Matlab/main/docs/window.png)

Entering values for the Rician K factor, the shadowing severity m, the root mean sqaure of the signal \hat{r}, and \phi the phase parameter:

![ScreenShot](https://raw.github.com/Jonathan-Browning/Shadowed-Rician-Fading-Matlab/main/docs/inputs.png)

The theoretical evenlope PDF and phase PDFs are plotted to compare with the simulation and gives the execution time for the theoretical calculations and simulations together:

![ScreenShot](https://raw.github.com/Jonathan-Browning/Shadowed-Rician-Fading-Matlab/main/docs/results.png)
