# Architecture Independent Mattermost Builder

This is a Dockerfile that can be used to build mattermost for any CPU architecture, provided that the user adjusts the ARCH environment variable before building it.   

See the mattermost/platform Makefile and .travis.yml for more details.

Here you go folks, an ARM-based builder for a leading Open Source web chat platform!
  * Leading is a metric defined entirely by me.  I like mattermost best because:
  * Golang means it is easily compiled for whatever platform
  * Provides an easy customer chat interface
  * They seem to "get it." 


# Note
* For the time being this is just something I put together, nothing more.  Please, tell me how it worked for you, though!  
* Not Used in the offical Mattermost x86/AMD64 travis CI build system.
