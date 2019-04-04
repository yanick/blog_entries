---
url: digging-dungeons
format: markdown
created: 2011-08-09
tags:
    - Perl
    - game
    - dungeons
---

# Extreme Makeover: Dungeons Edition

[Remember that game I have in the back-burner](/entry/maze), the one I described as being a
cross of 'X-Com' meets 'Dwarf Fortress'?

No? Well, no big surprise. After all, is it *way* at the back of the
back-burner stack. Anyway, as a quick recap: it's a game about colonial
marines blasting aliens in sinister caves to harvest their precious bodily 
fluids. Or something like that.  Important part is: I had some tuits lately,
and so I worked a little bit on one of the basics 
of that game. 

Specifically, I checked out how I could dig myself some caves.

I first thought I'd find some dungeon building modules already out there to do the deed,
but they are more rare than I expected. And the ones that do
exist insist on building rectangular rooms and straight corridors, which is
nice if you want the basement of a wizard's crib, but not so much if you want
to recreate the hive of those Starship Troopers' lovelies. 


Without readily available software to do my excavations, I decided to give it
a shot myself. To come up with an algorithm to create a decent dungeon or cave
system
was the hard part. At the end, I went with a very simple recipe that seems to 
gives fair results:

1. Begin with a blank grid.

2. Pick a random point on the grid that hasn't been excavated.

3. Excavate a room around that point.

4. If the room is not connected with the rest of the system,
pick a random point *A* in that room, and a random point *B*
in the rest of the system, and dig from *A* toward *B* 
until they connect.

5. Repeat 2 through 4 until there is enough rooms and tunnels to make you
happy.

Nice thing about this method, is that 
there are no specifics about how to excavate the rooms or
dig the tunnels. If you want a classic dungeons, you can
go all right angles on both, but if you desire something more
organic, you could set them to be a little more erratic.

Having figured out my intended approach, I first implement a generic digging role that
takes care of the main building logistic:

<galuga_code code="perl">Digger.pm</galuga_code>

With all the general excavation process encapsulated in that role, creating
the dungeon and cave builders is only a question of implementing different
flavors of `create_room` and `tunnel`.

<galuga_code code="perl">Dungeon.pm</galuga_code>

<galuga_code code="perl">Cave.pm</galuga_code>

Oh yes, and there is the map itself, which class is for the time being...
rather simple:

<galuga_code code="perl">Grid.pm</galuga_code>

It's not very nice to just use the underlying hash of the Moose class
like that, granted. But for the moment, it's good enough.

And that's all I need. Using that code, I can create different flavors of
maps. Or even better, use different diggers and assign them them different parts 
of a single map. For example, want a classic dungeon to open to darker caves?
No problem, the script

<galuga_code code="perl">mkdungeon.pl</galuga_code>

will generate an output looking like this

<pre style="font-size: 6pt">
############################################################
############################################################
####    ############## #####################################
####### ############## #####################################
####### ############## #####################################
####### ############## #####################################
#######  ############# #####################################
######## ############# #####################################
########                ####################################
########                                            ########
######## #              ######## ###############    ########
######## #              ######## ###############    ########
######## #              ######## #############  ############
######## #              ######## #############  ############
######## #                                            ######
######## ##     ####  ########################  ##### ######
######## ##     ####  ############################### ######
######## ##     ####  ############################### ######
######## ##     ####  ############################### ######
######## ##     ####  #################  ############ ######
######## ##     #######################  ############ ######
######## ##     #######################  ##########        #
######## ##     #######################  ##########        #
######## #### #########################  ##########        #
######## #### #########################  ##########        #
######## #### ######################### ###########        #
######## #### ######################### ###########        #
######## #### #########          ###### ###########        #
#######   ### #########          ###### ###########        #
#######   ### #########          ###### ############# ######
#######   ###                              ########## ######
#######   #############                    #########  ######
#######   ###################              #########  ######
#######   ###################              #########  ######
#######   ###################              #########  ######
#######   #####################            #########  ######
#######   #####################            #########  ######
###############################            #########  ######
###############################            #########  ######
###############################               ##############
#########                                     ##############
#########  ####################               ##############
#########  ####################               ##############
#########  #######       ######               ##############
##################                         #################
##################       ######            #################
############  ####       ######            #################
############  ####       ##########    #####################
############  ####       #######       #####################
############  ####       #####   ##    #####################
############             ####  #  #    #####################
############             ##   ##  ##########################
############        ######  ####  ##########################
############        ###### ####   ##########################
#########################  #### #     ######################
######################### ###   #####   ####################
############  ##########  ### #########  ###################
############  ###   #### #### ########## ###################
############   #         #### ########## ###################
##########         # ######## ##########     ###############
###############      ###      ############## ###############
##############      #### ################### ###############
##############      ##   ###################   #############
###############   ###  # ###########   #######   ###########
############     ###  ##  #########    #########  ##########
############    ##   #### ###########     # ################
###############    #####  ############      ################
#############   ########  ######## ###     #################
##########    ##########  #######   #      #################
########## #  ##########  #########  ## # ##################
########## # ########### ##########  #  ####################
#######      ########### ##########       ##################
######    # ############ ##########  #    ##################
#####    ## ############      #####       ##################
######    # #################    ##       ##################
######  # # ############  ######  #         ################
######### # ## #######   ######## #     #  #################
########       #######   ######## #        #################
########  ### ####       ######## ####       ###############
######### ########    #  ########   #      # ###############
##    ##  ########       ##########       #  ###############
##     ##   #######       ############       ###############
###      #  ######         #############  #     ############
#####       ###### ##    # ################     ############
####     ## #########       ############### ################
###      ## ########   #    ################################
##       ##     #####    #  ################################
### ###########   ### #  #  ################################
##############  # ###    #   ###############################
##############    ##     ###  ##############################
########### ##           ####  ###############  ############
###########  #          # ###################      #########
###########             #  ######  #########        ########
###########           #    #####   # ####### ###    ########
###########  ## #          ####      ###########   #########
#################                #        ####     #########
##################        # #    # ##  #   ### # ###########
#################      # #   #     #######      ############
##################  ##              #######  ###############
#################                   ########################
###############    ##               ########################
###############    #  #    ###     #########################
###############             ## ##  #########################
################### ##      #####  #########################
######################  ####################################
############################################################
</pre>


The code, as usual, is available [on GitHub](https://github.com/yanick/Games-DungeonBuilder)
(and should eventually make it to CPAN, once some documentation is injected
into the mix).
