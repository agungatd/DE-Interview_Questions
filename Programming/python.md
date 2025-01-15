# Python for Data Engineers

# Table of Contents

## Beginner

+ [How would you read a CSV file in Python and handle potential file-not-found errors?](#1-how-would-you-read-a-csv-file-in-python-and-handle-potential-file-not-found-errors)
+ [Explain the difference between a list and a tuple in Python. When would you use one over the other in data engineering?](#2-explain-the-difference-between-a-list-and-a-tuple-in-python-when-would-you-use-one-over-the-other-in-data-engineering)
+ [How would you remove duplicates from a list while preserving the order of elements?](#3-how-would-you-remove-duplicates-from-a-list-while-preserving-the-order-of-elements)

## Intermediate

+ [Write a decorator that measures the execution time of a function and logs it?](#q3)
+ [How would you implement a generator function that yields chunks of data from a large file to process it memory-efficiently?](#q4)
+ [Explain how you would use context managers to handle database connections safely, and write a simple context manager class](#q4)

## Advance

+ [Design a memory-efficient pipeline using generators to process a large dataset that doesn't fit in memory. Include error handling and logging?](#7-design-a-memory-efficient-pipeline-using-generators-to-process-a-large-dataset-that-doesnt-fit-in-memory-include-error-handling-and-logging)
+ [How would you implement a custom caching decorator that can handle both function arguments and keyword arguments, with a configurable cache size and expiration time?](#8-how-would-you-implement-a-custom-caching-decorator-that-can-handle-both-function-arguments-and-keyword-arguments-with-a-configurable-cache-size-and-expiration-time)
+ [Explain how you would implement a parallel data processing system using Python's multiprocessing module, ensuring proper handling of shared resources and process communication. Include code for a practical example](#9-explain-how-you-would-implement-a-parallel-data-processing-system-using-pythons-multiprocessing-module-ensuring-proper-handling-of-shared-resources-and-process-communication-include-code-for-a-practical-example)

## 1. How would you read a CSV file in Python and handle potential file-not-found errors?

concept: basic syntax & error handling

```python
# Example solution
def read_csv_safely(file_path):
    try:
        with open(file_path, 'r') as file:
            # Read file contents
            return file.readlines()
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return None
```

[Table of Contents](#Table-of-Contents)

## 2. Explain the difference between a list and a tuple in Python. When would you use one over the other in data engineering?

concept: data structures

Lists are mutable and better for changing data, while tuples are immutable and better for fixed data like database schemas or column names. Tuples also provide slight performance benefits and can be used as dictionary keys.

[Table of Contents](#Table-of-Contents)

## 3. How would you remove duplicates from a list while preserving the order of elements?

concept: data structures & error handling

```python
# Example solution
def remove_duplicates(lst):
    seen = set()
    return [x for x in lst if not (x in seen or seen.add(x))]
```

## 4. Write a decorator that measures the execution time of a function and logs it!

concept: Decorators

```python
import time
from functools import wraps

def timing_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"{func.__name__} took {end_time - start_time:.2f} seconds to execute")
        return result
    return wrapper
```

## 5. How would you implement a generator function that yields chunks of data from a large file to process it memory-efficiently?

concept: generators

```python
def chunk_file_reader(filename, chunk_size=1000):
    with open(filename, 'r') as file:
        chunk = []
        for i, line in enumerate(file, 1):
            chunk.append(line)
            if i % chunk_size == 0:
                yield chunk
                chunk = []
        if chunk:
            yield chunk
```

## 6. Explain how you would use context managers to handle database connections safely, and write a simple context manager class

concept: context managers

```python
class DatabaseConnection:
    def __init__(self, connection_string):
        self.connection_string = connection_string
        
    def __enter__(self):
        # Establish connection
        self.connection = self.connect(self.connection_string)
        return self.connection
        
    def __exit__(self, exc_type, exc_val, exc_tb):
        # Close connection even if an error occurred
        self.connection.close()
```

## 7. Design a memory-efficient pipeline using generators to process a large dataset that doesn't fit in memory. Include error handling and logging

concept: Memory optimization

```python
from typing import Generator, Any
import logging

class DataPipeline:
    def __init__(self, input_path: str, batch_size: int = 1000):
        self.input_path = input_path
        self.batch_size = batch_size
        logging.basicConfig(level=logging.INFO)
        
    def read_data(self) -> Generator[list, None, None]:
        try:
            with open(self.input_path, 'r') as f:
                batch = []
                for line in f:
                    batch.append(self.parse_line(line))
                    if len(batch) >= self.batch_size:
                        yield batch
                        batch = []
                if batch:
                    yield batch
        except Exception as e:
            logging.error(f"Error reading data: {str(e)}")
            raise
```

## 8. How would you implement a custom caching decorator that can handle both function arguments and keyword arguments, with a configurable cache size and expiration time?

concept: caching systems

```python
from functools import wraps
from collections import OrderedDict
import time

class TTLCache:
    def __init__(self, maxsize=128, ttl=3600):
        self.maxsize = maxsize
        self.ttl = ttl
        self.cache = OrderedDict()
        
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            key = str(args) + str(sorted(kwargs.items()))
            if key in self.cache:
                result, timestamp = self.cache[key]
                if time.time() - timestamp < self.ttl:
                    return result
                else:
                    del self.cache[key]
            
            result = func(*args, **kwargs)
            self.cache[key] = (result, time.time())
            
            if len(self.cache) > self.maxsize:
                self.cache.popitem(last=False)
                
            return result
        return wrapper
```

## 9. Explain how you would implement a parallel data processing system using Python's multiprocessing module, ensuring proper handling of shared resources and process communication. Include code for a practical example

concept: parallel processing

```python
from multiprocessing import Pool, Manager, Lock
import pandas as pd

class ParallelProcessor:
    def __init__(self, num_processes=4):
        self.num_processes = num_processes
        self.manager = Manager()
        self.lock = Lock()
        self.shared_dict = self.manager.dict()
        
    def process_chunk(self, chunk):
        try:
            # Process data
            result = self.transform_data(chunk)
            
            # Update shared resource safely
            with self.lock:
                self.shared_dict['processed_count'] = \
                    self.shared_dict.get('processed_count', 0) + len(chunk)
                
            return result
            
        except Exception as e:
            with self.lock:
                self.shared_dict['errors'] = \
                    self.shared_dict.get('errors', []) + [str(e)]
            return None
            
    def run_parallel(self, data):
        with Pool(self.num_processes) as pool:
            results = pool.map(self.process_chunk, 
                             np.array_split(data, self.num_processes))
        return pd.concat(results)
```
