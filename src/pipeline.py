"""Dag04-opgave: implementér en reproducerbar batch-pipeline.

Arbejd efter Dag04 i 20556_Laerling_Ugecase_NYC_Taxi.md.
Denne fil angiver kontrakten og funktionsgrænserne, men ikke løsningen.
"""
from pathlib import Path
import duckdb


DB_PATH = Path("data/warehouse/taxi_20556.duckdb")

# 01_explore.sql er udforskning og er bevidst ikke et rebuild-trin.
STEPS = (
    ("dimensions", Path("sql/02_dimensions.sql")),
    ("fact", Path("sql/03_fact_trip.sql")),
    ("aggregate", Path("sql/04_aggregates.sql")),
)


def load_statements(
    connection: duckdb.DuckDBPyConnection, sql_path: Path
) -> list[str]:
    """Læs og parse en påkrævet SQL-fil eller stop med en tydelig fejl."""
    if not sql_path.exists():
        raise FileNotFoundError(f"Kritisk fejl: Mangler påkrævet SQL-fil: {sql_path}")
    
    sql_text = sql_path.read_text(encoding="utf-8")
    
    try:
        parsed_statements = connection.extract_statements(sql_text)
        
        statements = [stmt.query for stmt in parsed_statements]
    except Exception as e:
        raise ValueError(f"Fejl ved parsing af SQL-fil {sql_path.name}: {e}")
    
    if not statements:
        raise ValueError(f"SQL-filen {sql_path.name} indeholder ingen kørbare statements.")
        
    return statements


def run_step(
    connection: duckdb.DuckDBPyConnection,
    step_name: str,
    statements: list[str],
) -> None:
    """Kør ét trin og gør det synligt, hvor en eventuel fejl opstår."""
    print(f"\n[TRIN] Starter: {step_name} ({len(statements)} statement(s))")
    
    for idx, stmt in enumerate(statements, 1):
        print(f"  -> Udfører statement {idx}/{len(statements)}...")
        try:
            result = connection.execute(stmt)
            if result and result.description:
                rows = result.fetchall()
                if rows:
                    print(f"     Kontrolresultat:")
                    for row in rows:
                        print(f"       {row}")
        except Exception as e:
            print(f"  [FEJL] Fejlede i trin '{step_name}' ved statement {idx}: {e}")
            raise


def main() -> None:
    """Kør hele builden sikkert i den rækkefølge, afhængighederne kræver."""
    print("=== Starter NYC Taxi Batch Pipeline (Dag 04) ===")
    
    #Opret warehouse
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    
    #Validér alle SQL-filer FØR build
    print("Validerer SQL-filer...")
    step_statements = {}
    
    temp_con = duckdb.connect(str(DB_PATH))
    try:
        for step_name, sql_path in STEPS:
            step_statements[step_name] = load_statements(temp_con, sql_path)
    finally:
        temp_con.close()
    
    print("Alle SQL-filer er valideret med succes.")
    
    #Start selve transaktionen og builden på den rigtige forbindelse
    connection = duckdb.connect(str(DB_PATH))
    
    try:
        connection.execute("BEGIN TRANSACTION;")
        
        for step_name, sql_path in STEPS:
            statements = step_statements[step_name]
            run_step(connection, step_name, statements)
            
        connection.execute("COMMIT;")
        print("\n=== Pipelinen gennemført succesfuldt! Transaktion committet. ===")
        
    except Exception as e:
        connection.execute("ROLLBACK;")
        print(f"\n[FEJL] Bygget fejlede. Transaktion rullet tilbage (ROLLBACK).")
        raise
    finally:
        connection.close()
        print("Databaseforbindelse lukket.")


if __name__ == "__main__":
    main()