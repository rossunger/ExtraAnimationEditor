# ExtraAnimationEditor
An alternate animation editor/player for Godot engine. 
WIP

# Features
[x] Timeline editing, with keyframes

Classic timeline editing with keyframes and curves. 

[x]. Live preview without affecting the original

In the animation editor, you can select a "preview context" which loads an instance of the scene you want to animate.
Any changes that are made here won't affect the original .tscn file.

[x]. Relative value keyframes

Keyframes can set absolute values (e.g. position.x = 30) or relative value (e.g. position.x += 30)

[x]. Easily change who each track is animating (parameterised)

Apply the same animation to different objects. Combined with relative value keyframes, you can apply e.g. the same a walk cycle animation to all your characters

[x] Set parameters from code.

Easily change who the animation is affecting, or what property is affected at runtime
Set keyframe values based on scripted logic. 

[x]. Modifiable playrate (play backwards, play speed modifier
Playback speed,

[x]. Preview in different contexts

[x]. Drag keyframes onto different tracks
Move, copy/paste, duplicate across tracks without hesitation

[_]. undo/redo 
Robust undo system that won't accidentally delete your work

[_]. Emit signals / call functions?
Keyframes can emit signals and call functions

[_]. Can have keyframes that are driven by other objects (as with Inverse Kinematics) 
Keyframes can be relative to other objects. E.g. look_at target 

[_]. Nested animations
Animations playing other animations. Parameters driving other parameters

[_]. Expression
Use of expressions/functions instead of keyframes e.g. sin(time) or noise functions to animate 

[_]. Onion skinning

[_]. Dope sheet with curves

[_]. Snapping and Grid

[_]. Zoom and Pan while editing

[_]. Preview Audio/Video while editing

[_]. Auto-keyframe LocationRotationScale
