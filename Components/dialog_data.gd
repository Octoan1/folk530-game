class_name DialogData
extends Resource

## Name shown above the text. Leave empty for none.
@export var speaker: String = ""
## One entry per box of text. Keep lines short, since the screen is small.
@export_multiline var lines: PackedStringArray
