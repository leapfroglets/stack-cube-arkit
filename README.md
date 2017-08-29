#  Stack Cube

The main motivation to this app was to have some ideas and research on ARKit.

ARKit has its own view known as ARSCNView that allows real world scene to render through camera. This view has its session(ARSession) that reads data from the device's motion sensing hardware, controlls the device's built-in camera, and performs image analysis on captured camera images. To run the session we provide some configuration(ARConfiguration) to it. Since we want to track our world we use world tracking session(ARWorldTrackingConfiguration). Since we are placing cube to the plane, we place a virtual plane to the real world plane. For this we enable plane detection on session configuration. With plane detection configuration on, the plane in the real world is detected and ARKit provides anchor(translation, rotation, center and extent vector) of that respective plane. Using that anchor we can place geometric object to the real world. Here we place a plane to the real world. On taping around the plane, a cube(geometric box) falls from certain height and is placed into the plane. The cube behaves as a physics body(with gravity and act to collision) and its visible that the cube is placed into the real environment.

The screenshot to this app is here:

![Alt text](//blob/master/Screenshot/stackcube.PNG?raw=true "Stack Cube")