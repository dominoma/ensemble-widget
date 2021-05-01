import computeMunkres from "munkres.mjs"


export function loadFile(filename) {
    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhr.open("GET", filename);
        xhr.onreadystatechange = () => {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 0) {
                    reject(new Error(xhr.statusText))
                } else {
                    resolve(xhr.responseText)
                }
            }
        }
        xhr.onerror = (err) => reject(err)
        xhr.send();
    })
}

export function loadDRData(filename, ensembleCount = 51) {
    return loadFile(filename).then((response) => response
        .split("\n")
        .map((line, index) => {
            const match = /cl\d+  \: (.*)\s(.*)/.exec(line)
            if (!match) {
                return null
            }
            return {
                ensemble: index % ensembleCount,
                x: parseFloat(match[1]),
                y: parseFloat(match[2])
            }
        })
        .reduce((acc, el) => {
            if (!el) return acc
            if (!acc[el.ensemble]) acc[el.ensemble] = []
            acc[el.ensemble].push({
                x: el.x,
                y: el.y
            })
            return acc
        }, []))

}

function loadClusterings(filename) {
    return loadFile(filename).then((response) => response
        .split("\n")
        .filter((el) => !!el)
        .map((line) => /cl\d+  = \[ ([\d+ ]*) \];/.exec(line)[1].split(' ')
            .map((el) => parseInt(el, 10))))
}

export function transposeMatrix(matrix) {
    if(matrix.length === 0) {
        return []
    }

    return matrix[0].map((_, colIndex) =>
        matrix.map(row => row[colIndex]))
}
export function objFromEntries(entries) {
    return entries.reduce((acc, [key, val]) => {
        acc[key] = val
        return acc
    }, {})
}

export function loadClusterData(filename) {
    return loadClusterings(filename)
        .then((clusterings) => optimizeClusterings(clusterings))
        .then((clusterings) => transposeMatrix(clusterings))
}

function optimizeClusterings(clusterings) {
    const getRowDifferenceCount = (oldRow, newRow, from, to) => {
        const replace = (el) => el === from ? to : el
        return oldRow.reduce((acc,_,index) => {
            return acc + (oldRow[index] !== replace(newRow[index]))
        }, 0)
    }
    const getRowsDifferenceCount = (oldRows, newRow, from, to) => {
        return oldRows.reduce((acc, oldRow) => {
            return acc + getRowDifferenceCount(oldRow, newRow, from, to)
        }, 0)
    }
    const getDifferenceMatrix = (oldRows, newRow, clusterCount) => {
        const matrix = []
        for (let x = 0; x < clusterCount; x++) {
            matrix.push([])
            for (let y = 0; y < clusterCount; y++) {
                matrix[x].push(getRowsDifferenceCount(oldRows, newRow, x, y))
            }
        }
        return matrix
    }
    const optimizeClustering = (optimizedRows, newRow, clusterCount) => {
        if (optimizedRows.length === 0) {
            return newRow
        }
        const matrix = getDifferenceMatrix(optimizedRows, newRow, clusterCount)
        const replacementMatrix = computeMunkres(matrix)
        return newRow.map((el) => replacementMatrix[el][1])
    }

    const clusterCount = clusterings[0]
        .concat()
        .sort((a, b) => b - a)[0] + 1

    const optimizedRows = []
    for (let oldRow of clusterings) {
        const optimizedRow = optimizeClustering(optimizedRows, oldRow, clusterCount)
        optimizedRows.push(optimizedRow)
    }
    return optimizedRows
}
