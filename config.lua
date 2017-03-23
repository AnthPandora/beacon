-- This file contains configuration variables that will affect beacons beahaviour

-- Int. : Raduis of beacons effect.
beacon.config.effects_radius = 30

-- Int. : How long before beacons check for new players in the area.
beacon.config.timer_timeout = 2.0

-- Str. : Chat and console messages will be prefixed by this.
beacon.config.msg_prefix = "[Beacon] "

-- Bool. : Does the beam break nodes (other that air)
beacon.config.beam_break_nodes = false

-- Bool. : Allow placing beacon inside the radius of another beacon.
beacon.config.beacon_distance_check = true

-- Bool. : Should the blue beacon area be delimited with a visible field.
beacon.config.blue_field = false

-- Bool. : If true, players wont be able to get in or out of the blue field
beacon.config.blue_field_solid = false
