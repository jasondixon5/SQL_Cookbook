# Assign group number consecutively
# e.g., 1 1 1 1 2 2 2 2 ...

from math import ceil

def assign_group_number(rows, bucket_count=4):

    """
    Begin with 1 as group number
    Begin with 1 as count of rows seen
    For each row:
    - increment count of rows seen
    - if rows seen <= bucket count:
      -- assign group number 1
    - else:
      -- increment group number += 1
      -- reset rows seen to 1
    
    Note that this solution intentionally avoids the "rank rows and then take modulo"
    approach
    """
    from math import ceil

    count_per_bucket = ceil(len(rows)/bucket_count)
    row_count_seen = 0
    group_number = 1
    group_numbers = []

    for x in rows:

        row_count_seen += 1

        #print(x)
        #print("Group #: {}".format(group_number))
        #print("Row Count Seen: {}".format(row_count_seen))
        #print("Row count seen <= count per bucket: {}".format(
        #    row_count_seen <= count_per_bucket))

        if row_count_seen <= count_per_bucket:
            group_numbers.append(group_number)
            #row_count_seen += 1
        else:
            group_number += 1
            group_numbers.append(group_number)
            row_count_seen = 1

        
        #print("AFTER")
        #print("Group #: {}".format(group_number))
        #print("Row Count Seen: {}".format(row_count_seen))
        #print("\n")

    print("Rows: ")
    print(rows)
    print("# of buckets: {}".format(buckets))
    print("Count per bucket: {}".format(count_per_bucket))
    print("\n")

    return zip(group_numbers, rows)

test_rows = [
    "Smith", "Allen", "Ward", "Jones",
    "Martin", "Blake", "Clark", "Scott",
    "King"
]

buckets = 3
test_groups = assign_group_number(test_rows, bucket_count=buckets)
for x in test_groups:
    print(x)

buckets = 4
test_groups = assign_group_number(test_rows, bucket_count=buckets)
for x in test_groups:
    print(x)

buckets = 5
test_groups = assign_group_number(test_rows, bucket_count=buckets)
for x in test_groups:
    print(x)

test_rows = [
    "Smith", "Allen", "Ward", "Jones",
    "Martin", "Blake", "Clark", "Scott",
    "King", "Turner", "Adams", "James",
    "Ford", "Miller"
]

buckets = 4
test_groups = assign_group_number(test_rows, bucket_count=buckets)
for x in test_groups:
    print(x)
