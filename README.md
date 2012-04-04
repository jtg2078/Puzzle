# Puzzle

## Setup


### Clone from github
+ `git clone git://github.com/jtg2078/Puzzle.git`
+ `cd puzzle`
+ `git submodule update --init`

## About this project

### Introduction
Lets build a slider puzzle~

### Description
This project is about building a slider puzzle app that allows users to move tiles(or blocks) by either tapping them, or sliding them with touches. For the sliding part, the users can slide row or column of tiles if applicable.

### Implementation detail
#### Animating the tiles
To animate the movement of blocks, I've decided to use `[UIView animateWithDuration…]` and utilize the duration parameter to control the pace of the block movement. The end result is somewhat satsifactory, but could definitely be better. One other way that I can think of, which probably give a smoother transition is to use `[CADisplayLink displayLinkWithTarget…]` and control the position of blocks. Will definite try it on the next update… 
#### Moving the tiles
User interactions, mainly the touches, are being handled by UIGestureRecognizer. Two types of gesture recognizer are used in the project, *UITapGestureRecognizer* and *UIPanGestureRecognizer*. I choose to use gesture recognizers instead of `[UIView touchesBegan…]` and related methods are mainly because they are easier to implement and go rather well with `[UIView animateWithDuration…]`. Again, if we are going to use the `[CADisplayLink displayLinkWithTarget…]`, then it is probably better to switch to `[UIView touchesBegan…]` to handle user touches.
#### Miscellaneous
Testlfight is used(added as submodule)