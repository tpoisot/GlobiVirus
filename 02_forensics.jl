using JSON3
using StatsBase

gb = JSON3.read("compact.json")

countmap([i.as for i in gb])


filter(i -> i.as == "hostOf", gb)

