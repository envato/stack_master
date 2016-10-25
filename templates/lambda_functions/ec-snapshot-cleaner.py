import boto3
import re
import datetime

EC = boto3.client('elasticache')

def lambda_handler(event, context):
    # Get region and account number from the invokedFunctionArn attribute of the context
    # arn:aws:lambda:region:account-id:function:function-name
    (region, accountNumber) = context.invoked_function_arn.split(':')[3:5]

    apiResponse = EC.describe_snapshots(
        SnapshotSource='user'
    )
    ecSnapshots = apiResponse['Snapshots']
    while 'Marker' in apiResponse:
        apiResponse = EC.describe_snapshots(
            SnapshotType='user',
            Marker=apiResponse['Marker']
        )
        ecSnapshots.extend( apiResponse['Snapshots'] )

    # Delete anything tagged DeleteOn with this value
    now = datetime.datetime.now()
    print "Looking for items tagged DeleteAfter with a value of %s" % now
    for snapshot in ecSnapshots:
        tags = EC.list_tags_for_resource(
            ResourceName = "arn:aws:elasticache:%s:%s:snapshot:%s" % ( region, accountNumber, snapshot['SnapshotName'] )
        )['TagList']
        deleteAfterTag = next((item for item in tags if item['Key'] == 'DeleteAfter'), None)
        if deleteAfterTag:
            deleteAfter = datetime.datetime.strptime(deleteAfterTag['Value'], '%Y-%m-%d-%H-%M-%S')
            if deleteAfter < now:
                print "Deleting snapshot %s" % snapshot['SnapshotName']
                EC.delete_snapshot(SnapshotName=snapshot['SnapshotName'])
