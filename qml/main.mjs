import * as DataFunctions from "js/dataFunctions.mjs"

WorkerScript.onMessage = () => {
    Promise.all([
        DataFunctions.loadDRData("../data/exportSpecPC.txt"),
        DataFunctions.loadClusterData("../data/KMeans_5_Clusters_all.txt"),
        DataFunctions.loadClusterData("../data/Spectral_8_Clusters_all.txt")]
    ).then(([pca, kmeans, spectral]) => {
        const ensembleData = pca.map((_, index) => ({
            dr: [
                { name: "PCA", data: pca[index] },
                { name: "t-SNE", data: pca[index] },
                { name: "UMAP", data: pca[index] }
            ],
            cluster: [
                { name: "k-Means", data: kmeans[index] },
                { name: "Spectral", data: spectral[index] }
            ]
        }))
        WorkerScript.sendMessage(ensembleData)
    }).catch((e) => console.error(e, e.stack))
}

