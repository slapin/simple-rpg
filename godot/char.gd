extends Spatial

var chdata
var enemy = false
var xtrans = 0
var ztrans = 0
var model
var inventory = []
func place_char():
        var ch = chdata
        if enemy:
                xtrans = 10 + 2 * ch["row"]
        else:
                xtrans = -10 - ch["row"]
        ztrans = -9 + 2 * ch["place"]
func spawn():
        set_translation(Vector3(xtrans, 0.0, ztrans))
        if enemy == 0:
                set_rotation(Vector3(0.0, -3.1415926 / 2, 0.0))
        else:
                set_rotation(Vector3(0.0, 3.1415926 / 2, 0.0))
        print("trans:", get_translation(), "rot:", get_rotation())
        add_child(model.instance())
        show()
func ai_turn(target):
        print(get_name(), " AI attacks ", target.get_name())
func attack(target):
        pass
func spell(target):
        pass
func capture(target):
        pass
func inventory_get():
        return inventory
func inventory_add(item):
        inventory.append(item)
func inventory_remove(item):
        inventory.remove(item)
func get_name():
        return chdata["name"]
func _init(ch, en, m):
        chdata = ch
        enemy = en
        place_char()
        model = m

