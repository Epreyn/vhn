const functions = require("firebase-functions");
const firestore = require("@google-cloud/firestore");
const Console = require("console");
const client = new firestore.v1.FirestoreAdminClient();

const bucket = "gs://vins-hors-normes.appspot.com";

exports.scheduledFirestoreExport = functions.pubsub
    .schedule("every 24 hours")
    .onRun((context) => {
        const projectId = process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT;
        const databaseName = client.databasePath(projectId, "(default)");
        return client
            .exportDocuments({
                name: databaseName,
                outputUriPrefix: bucket,
                collectionIds: [],
            })
            .then((responses) => {
                const response = responses[0];
                console.log(response);
            })
            .catch((err) => {
                console.error(err);
                throw new Error("Export operation failed");
            });
    });
