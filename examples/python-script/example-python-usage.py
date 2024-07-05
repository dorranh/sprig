from pprint import pprint

from sprig.basket import LocalBasket
from sprig.model import LocalStorageConfig, Rows


def main():
    print("This is an example script which leverages sprig. Let's get started.")

    basket = LocalBasket("./sprigs")

    print("First lets list the sprigs available to us:")
    pprint(basket.list_sprigs())

    print("Running first example 'analysis'")
    my_analysis(basket)

    print("Running a second analysis script which depends on the output of the first")
    another_analysis(basket)


def my_analysis(basket: LocalBasket):
    "Reads a pre-existing sprig"
    print("Getting sprig for further analysis...")
    sprig = basket.get_sprig("demo-sprig")

    print("Now we can read it. Let's output it as a Pandas Dataframe:")
    df = basket.read_sprig(sprig.name).to_pandas()
    print(df)

    print("Updating our data to include a new column")
    # Do some stuff to the data
    df["new_column"] = 4242
    print(df)

    print(
        "If we want to save this as a "
        "new sprig for consumption downstream we can do that too"
    )

    # When we create a sprig from some in-memory data, it gets written to the
    # specified storage.
    new_sprig = basket.create_from_rows(
        "my-new-sprig",
        Rows.from_pandas(df),
        LocalStorageConfig(path="example-data/my-updated-data.csv"),
    )

    print("The new sprig:")
    print(new_sprig)


def another_analysis(basket: LocalBasket):
    """Depends on sprig generated in my_analysis"""
    sprig = basket.get_sprig("my-new-sprig")
    print(sprig)
    df = basket.read_sprig(sprig.name).to_pandas()
    print(df)


if __name__ == "__main__":
    main()
