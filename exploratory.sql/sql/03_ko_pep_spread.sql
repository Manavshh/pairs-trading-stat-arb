SELECT
    ko.date,
    ko.close AS ko_close,
    pep.close AS pep_close,
    ko.close - pep.close AS spread
FROM (SELECT date, close FROM prices WHERE ticker = 'KO') ko
JOIN (SELECT date, close FROM prices WHERE ticker = 'PEP') pep
    ON ko.date = pep.date
ORDER BY ko.date DESC
LIMIT 20;