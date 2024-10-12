# Working from release 0.7 of
# https://zenodo.org/records/11552565

using SQLite
using DataFrames

path = "globi.db"

db = SQLite.DB(path)

q = """
    SELECT sourceTaxonName, interactionTypeName, targetTaxonName, COUNT(interactionTypeName) AS hits
    FROM interactions
    WHERE
        (sourceTaxonKingdomName LIKE "%virae") AND
        (NOT interactionTypeName = "hasHost") AND
        (NOT interactionTypeName = "pathogenOf")
    GROUP BY
        sourceTaxonName, interactionTypeName, targetTaxonName
    ORDER BY
        hits DESC
    LIMIT 1000
    """

out = DBInterface.execute(db, q) |> DataFrame

# Predicted interactions

DBInterface.execute(
    db,
    """
SELECT sourceTaxonName, interactionTypeName, targetTaxonName
FROM interactions AS i1
WHERE
    (sourceTaxonKingdomName LIKE "%virae") AND
    (sourceBasisOfRecordName = "prediction")
ORDER BY
    sourceTaxonName, targetTaxonName
LIMIT 2000
"""
) |> DataFrame

# Interactions that make no sense

DBInterface.execute(
    db,
    """
SELECT DISTINCT sourceTaxonName, sourceTaxonGenusName, interactionTypeName, COUNT(*) AS hits
FROM interactions AS i1
WHERE
    (sourceTaxonKingdomName LIKE "%virae") AND
    (NOT interactionTypeName = "hasHost") AND
    (NOT interactionTypeName = "hasVector") AND
    (NOT interactionTypeName = "pathogenOf") AND
    (NOT interactionTypeName = "interactsWith") AND
    (NOT interactionTypeName = "endoparasiteOf")
GROUP BY
    sourceTaxonName, interactionTypeName
ORDER BY
    hits DESC
LIMIT 200
"""
) |> DataFrame
