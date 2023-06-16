from airflow.decorators import dag, task

@dag
def example():

    @task
    def extract():
        return [1, 2, 3]
    
    @task
    def transform(x):
        return x * 2
    
    @task
    def load(y):
        print(y)

    data = extract()
    transformed = transform.map(data)
    load(transformed)
    
