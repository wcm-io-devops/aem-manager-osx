wcm.io AEM Manager for MacOS  Sierra
===============================

Taskbar application for managing AEM instances on MacOS Sierra.

There is also a version for Windows:
https://github.com/wcm-io-devops/aem-manager


Overview
---------

The AEM manager is a MacOS Sierra application that allows to manage local AEM instances for AEM developers. It allows to start, stop instances in the menubar. Via menubar quick links are available to the most important entry points.


Installation
------------

* Download the latest release from the [Releases](https://github.com/wcm-io-devops/aem-manager-osx/releases) section.
* Install DMG File to your Applications Folder. The DMG File is not signed, so enable GateKeeper for App-Download from anywhere in your security settings.

*  In case  of Problems  especially  with MacOS  Versions  <  10.12  installing  Release  Versions <  0.1.6 may help.

Relase 0.1.5 tested with OS X 10.11 El Capitan 

Release 0.1.6 tested with MacOS 10.12 Sierra.


Features
--------

After starting the AEM manager a table with the instances is shown:

![AEM Manager on Startup](/images/aem-manager-startup.png)

You can define new instances:

![AEM Instance](/images/aem-instance.png)

The main menubar icon offers a context menu with some global useful links, and the possible to choose for which instances a separate icon should be displayed in the taskbar:

![AEM Manager Context Menu](/images/aem-manager-context-menu.png)

For each instance icon a context menu offers to start/stop the instance, open log files or open a browser to jump into different entry points:



Known Bugs
----------

* No JProfiler Support
* Some java args seems not supported by NSTask()


Issue Tracking
--------------

For bugs and enhancement requests please file a ticket at https://wcm-io.atlassian.net/projects/WDEVOP
