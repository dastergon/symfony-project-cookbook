name             'activelamp_symfony'
maintainer       'Bezalel Hermoso, ActiveLAMP'
maintainer_email 'bez@activelamp.com'
license          'Apache 2.0'
description      'Cookbook for deploying Symfony2 projects.'
long_description 'Cookbook for deploying Symfony2 projects.'
version          '0.0.1'

depends 'activelamp_composer', '~>0.0.1'

provides 'symfony_project[/path/to/deploy]'
provides 'app_console[/path/to/deploy/current]'

supports 'ubuntu'
supports 'debian'
