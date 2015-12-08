AEM Manager
==================

Taskbar application for managing AEM instances on Mac OSX.


Overview
---------

The AEM manager is a Mac OSX application that allows to manage local AEM instances for AEM developers. It allows to start, stop instances and monitor their bundles statuses in the menubar. Via menubar quick links are available to the most important entry points.


Installation
------------

* TODO

Tested with OSX 10.11 El Capitan.


Features
--------

After starting the AEM manager a table with the instances is shown:

![AEM Manager on Startup](/images/aem-manager-startup.png)

You can define new instances:

![AEM Instance](/images/aem-instance.png)

The main menubar icon offers a context menu with some global useful links, and the possible to choose for which instances a separate icon should be displayed in the taskbar:

![AEM Manager Context Menu](/images/aem-manager-context-menu.png)

For each instance icon a context menu offers to start/stop the instance, open log files or open a browser to jump into different entry points:

![AEM Instance Context Menu](/images/aem-instance-context-menu.png)

Known Bugs
----------
* No JProfiler Support
* Some java args seems not supported by NSTask()
