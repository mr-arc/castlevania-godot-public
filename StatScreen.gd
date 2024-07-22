extends MarginContainer

func _ready():
	var stats = Stats.localStats
	$"%Score".text = str(stats["Score"])
	$"%Stage".text = str(stats["Max Stage Reached"])
	
	loadDeaths(stats)
	
	loadKills(stats)
	
	
func loadDeaths(stats: Dictionary):
	var deathGrid: = $"%DeathGrid"
	var totalDeaths = 0
	var deaths = stats["Deaths"] as Dictionary
	var keys = deaths.keys()
	keys.sort()
	for key in keys:
		var deathLabel = Label.new()
		deathLabel.text = "  - %s " % key
		var countLabel = Label.new()
		countLabel.text = str(deaths[key])
		totalDeaths += deaths[key]
		
		deathGrid.add_child(deathLabel)
		deathGrid.add_child(countLabel)
	$"%DeathTotal".text = str(totalDeaths)
	
func loadKills(stats: Dictionary):
	var killGrid: = $"%Kills"
	var totalKills = 0
	var kills = stats["Kills"] as Dictionary
	var keys = kills.keys()
	keys.sort()
	for key in keys:
		var enemyLabel = Label.new()
		enemyLabel.text = key + " "
		var countLabel = Label.new()
		countLabel.text = str(kills[key])
		countLabel.size_flags_horizontal = SIZE_EXPAND_FILL
		totalKills += kills[key]
		
		killGrid.add_child(enemyLabel)
		killGrid.add_child(countLabel)
	$"%KillTotal".text = str(totalKills)
