from airflow.decorators import dag, task
from airflow.utils.dates import days_ago


default_args = {
    'owner': 'airflow',
}


@dag(
    default_args=default_args,
    schedule_interval=None,
    start_date=days_ago(2), tags=['example']
)
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

example()