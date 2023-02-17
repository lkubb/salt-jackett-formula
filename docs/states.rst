Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``jackett``
^^^^^^^^^^^
*Meta-state*.

This installs the jackett containers,
manages their configuration and starts their services.


``jackett.package``
^^^^^^^^^^^^^^^^^^^
Installs the jackett containers only.
This includes creating systemd service units.


``jackett.config``
^^^^^^^^^^^^^^^^^^
Manages the configuration of the jackett containers.
Has a dependency on `jackett.package`_.


``jackett.service``
^^^^^^^^^^^^^^^^^^^
Starts the jackett container services
and enables them at boot time.
Has a dependency on `jackett.config`_.


``jackett.clean``
^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``jackett`` meta-state
in reverse order, i.e. stops the jackett services,
removes their configuration and then removes their containers.


``jackett.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the jackett containers
and the corresponding user account and service units.
Has a depency on `jackett.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``jackett.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the jackett containers
and has a dependency on `jackett.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``jackett.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the jackett container services
and disables them at boot time.


