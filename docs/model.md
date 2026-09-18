# Datamodel

**Version 1.2 · Elevskabelon**

## Indhold

1. [Første modelskitse](#1-første-modelskitse)
2. [Grain](#2-grain)
3. [Measures og dimensions](#3-measures-og-dimensions)
4. [Relationer og roller](#4-relationer-og-roller)
5. [Modeldiagram](#5-modeldiagram)
6. [Kontroller](#6-kontroller)
7. [Forklaring og kilder](#7-forklaring-og-kilder)

---

# 1. Første modelskitse

Vælg 2–3 analysebehov fra mandag. Skriv kort, hvilke oplysninger modellen skal gøre nemme at bruge.


Tegn en første modelskitse med almindelige ord, før du færdiggør den formelle model.

> [Start-zoner] ---> (Ture i midten) <--- [Slut-zoner]
>                          ^
>                          |
>                    [Datoer/Tid]
# 2. Grain

Formulér hvad én række i `fact_trip` repræsenterer.

> Én række i `fact_trip` repræsenterer én enkelt fuldført taxatur udført af en gul taxa i New York, baseret på rådata fra `yellow_tripdata_2025-01.parquet`.

Forklar hvorfor dette grain passer til dine analysebehov.

> Dette grain er på det mest detaljerede (atomare) niveau i rådata. Det gør det muligt at aggregere data op på tværs af zoner, datoer, betalingstyper og distancemæssige fordelinger, uden at vi mister præcision i vores analyser.
> TODO

# 3. Measures og dimensions

**Vigtigste measures:**
> - `trip_distance` (turens længde)
> - `fare_amount` (selve kørselstaksten)
> - `tip_amount` (drikkepenge)
> - `total_amount` (samlet beløb)

**Vigtigste dimensions:**
> - `dim_zone` (lokationer med Borough, Zone og Service Zone)
> - `dim_date` (datoer opdelt i ugedag, måned, år osv.)
> - `payment_type` (betalingsmetode)

Forklar kort forskellen på en measure og en dimension i din model.

> En **measure** er en numerisk, additiv værdi, som vi kan foretage beregninger på (f.eks. sum af omsætning eller distance). En **dimension** er den kontekst, vi filtrerer og grupperer vores measures ud fra (f.eks. *hvor* foregik turen, eller *hvornår* fandt den sted).

# 4. Relationer og roller

Forklar hvordan `dim_zone` bruges i pickup- og dropoff-rollen.

> `dim_zone` bruges to forskellige stedet, som er i `fact_trip` (`PULocationID` og `DOLocationID`). 

Forklar hvordan `dim_date` bruges i pickup- og dropoff-rollen.

> Ligesom zonerne bruges `dim_date` til at koble både afhentnings- og afleveringstidspunktet (`tpep_pickup_datetime` og `tpep_dropoff_datetime`) til en samlet dato-dimension, så vi kan analysere tidsmønstre for både start og slut på turene.

# 5. Modeldiagram

Tegn dit eget diagram med tabeller, nøgler, relationer og roller.

> ```text
>     [dim_date (Pickup)]        [dim_zone (Pickup)]
>             \                 /
>              \               /
>               v             v
>                  [ fact_trip ] <------ (DOLocationID - Dropoff Role)
>                       ^
>                       |
>              [dim_date (Dropoff)]
>                       |
>                       v
>                [ dim_zone ]
> ```

# 6. Kontroller

Beskriv hvilke kontroller du har lavet.

> - **Entydige dimensionsnøgler:** Vi har tjekket, at primærnøglen (f.eks. `LocationID` i `dim_zone`) er unik uden dubletter.
> - **Dato-dækning:** `dim_date` dækker fuldt ud det tidsrum, som findes i datasetts pickup- og dropoff-tidsstempler.
> - **Join-konsistens:** Vi har anvendt `LEFT JOIN` mod zone-opslag for at sikre, at ukendte eller manglende LocationIDs ikke sletter gyldige fact-rækker, men i stedet håndteres korrekt.
> - **Fact-rækkeantal:** Vi har kontrolleret, at tilføjelsen af dimensionerne ikke eksploderer rækkeantallet (dvs. at forholdet mellem fact og dimensioner er 1-til-mange, så én tur ikke duplikeres).

# 7. Forklaring og kilder

Begrund grain, valgte measures og dimensions ud fra analysebehovene. Forklar dimensionernes roller, og vis hvordan du kontrollerer modellens relationer.

> Modellen er bygget op som et klassisk Star Schema. Grain'et er sat til én række pr. tur, da det understøtter alle vores opstillede analysebehov omkring zoner, økonomi og distancer. Brugen af dimensions (`dim_zone` og `dim_date` til pickup og dropoff) sikrer, at vi kan analysere geografiske og tidsmæssige forskelle fra start til slut uden at duplicere unødvendig tabelinfrastruktur.

Angiv de kilder, du har anvendt, fx dataordbog, DuckDB-dokumentation eller Kimball-begreber.

> - NYC Taxi & Limousine Commission (TLC) Trip Record Dataordbog.
> - DuckDB Dokumentation.