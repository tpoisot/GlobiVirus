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

# List number of records for each interaction type for viruses
query_interaction_source = """SELECT
    DISTINCT interactionTypeName, COUNT(*) AS hits, COUNT(DISTINCT sourceTaxonName) AS virus, COUNT(DISTINCT targetTaxonName) AS other
    FROM interactions
    WHERE (sourceTaxonKingdomName LIKE "%virae") 
    GROUP BY interactionTypeName
    ORDER BY hits DESC
"""
query_interaction_target = """SELECT
    DISTINCT interactionTypeName, COUNT(*) AS hits, COUNT(DISTINCT sourceTaxonName) AS other, COUNT(DISTINCT targetTaxonName) AS virus
    FROM interactions
    WHERE (targetTaxonKingdomName LIKE "%virae")
    GROUP BY interactionTypeName
    ORDER BY hits DESC
"""
int_source = DBInterface.execute(db, query_interaction_source) |> DataFrame
int_target = DBInterface.execute(db, query_interaction_target) |> DataFrame


# List of predictions with feasible interactions that come from a prediction
query_predicted = """SELECT
    DISTINCT sourceTaxonFamilyName, targetTaxonOrderName, COUNT(*) as hits, COUNT(DISTINCT sourceTaxonName) AS virus, COUNT(DISTINCT targetTaxonName) AS host
    FROM interactions
    WHERE (sourceTaxonKingdomName LIKE "%virae") 
    AND (NOT sourceBasisOfRecordName = "prediction")
    GROUP BY sourceTaxonFamilyName, targetTaxonOrderName
    ORDER BY hits DESC
"""
DBInterface.execute(db, query_predicted) |> DataFrame

# Quality of evidence for Chiroptera - Coronaviridae
query_corobat = """SELECT
    DISTINCT sourceTaxonGenusName, targetTaxonSpeciesName, sourceBasisOfRecordName, COUNT(*) as hits
    FROM interactions 
    WHERE (sourceTaxonFamilyName = "Coronaviridae")
    AND (targetTaxonOrderName = "Chiroptera")
    AND (sourceTaxonGenusName IS NOT "")
    AND (targetTaxonSpeciesName IS NOT "")
    GROUP BY sourceTaxonGenusName, targetTaxonSpeciesName, sourceBasisOfRecordName
    ORDER BY hits DESC
"""
DBInterface.execute(db, query_corobat) |> DataFrame

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
