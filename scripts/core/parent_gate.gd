class_name ParentGate
extends RefCounted
## A sum a 3-year-old cannot solve, shown before any parent-only screen.


static func make(rng: RandomNumberGenerator) -> Dictionary:
	var a := rng.randi_range(3, 9)
	var b := rng.randi_range(3, 9)
	var answer := a + b
	var choices := [answer]
	while choices.size() < 4:
		var c := rng.randi_range(6, 18)
		if not choices.has(c):
			choices.append(c)
	for i in range(choices.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = choices[i]
		choices[i] = choices[j]
		choices[j] = tmp
	return {"text": "%d + %d = ?" % [a, b], "answer": answer, "choices": choices}


static func check(q: Dictionary, choice: int) -> bool:
	return choice == int(q.answer)
