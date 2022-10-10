AllSnapse is a combined SN P design tool and CPU-multithreaded SN P simulator implemented atop the Godot 3.5 engine.

Input Neurons, Regular Neurons, and Output Neurons are all supported.

AllSnapse introduces a new, simplified rule entry syntax, but Websnapse-esque rule syntax is also supported.

Other useful features of AllSnapse include:

A neuron duplicator (only for input neurons and regular neurons, since it makes no sense to duplicate output neurons)

Full support for click and drag, with collision between neurons and the drawing area to prevent overlapping and out-of-bounds neuron spawning.

Light-up whenever an input neuron reaches a spike on its spike train or when a neuron commits to a rule(forgetting rules included)

Exportable log of which neurons committed to which rule at what time, and how many spikes the firing neuron had on committing

Rule Preview on all regular neurons

...

And more!


You can download the Godot engine and import AllSnapse as a project if you are interested in developing, or you can head over to:

https://drive.google.com/drive/folders/1P4kBocvxDmBwWfE25CEuuXRUuk6GZroo?usp=sharing

For the latest Windoes/Linux binary releases and a changelog in plain English(Alternatively, you can trace git commits).


To use the link provided above, you must have UP email. If you do not have UP email, just download Godot 3.5 from:

https://godotengine.org/

and export AllSnapse to the platform of your choice.

Do note however that there are some graphical scaling issues for mobile devices and HTML5, but you are welcome to fix them and contribute your changes back to the official AllSnapse.


If you want to contribute to the official AllSnapse, you must be willing to license your contributions under 0BSD also.

Optionally, if you wish to identify yourself as a contributor, you may edit the About window and LICENSE.txt to identify yourself.

However, if you cannot or will not license your contributions under 0BSD, you are free to fork AllSnapse.
