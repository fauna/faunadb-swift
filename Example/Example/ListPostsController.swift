import UIKit
import FaunaDB

class ListPostsController: UITableViewController {

    private var refsAndTitles: [Post.RefAndTitle] = []
    private var nextPage: Value?

    override func viewDidLoad() {
        self.refreshControl?.addTarget(
            self,
            action: #selector(ListPostsController.handleRefresh(refreshControl:)),
            for: .valueChanged
        )

        reloadPosts()
    }

    @objc private func handleRefresh(refreshControl: UIRefreshControl) {
        // Map using the .main DispatchQueue because that is the only
        // queue allowed to update the UI
        reloadPosts().map(at: .main) {
            refreshControl.endRefreshing()
        }
    }

    @discardableResult private func reloadPosts() -> QueryResult<Void> {
        return Post.loadRefsAndTitles().map(at: .main) { [weak self] page -> Void in
            if let `self` = self {
                self.refsAndTitles = page.refsAndTitles
                self.nextPage = page.nextPage
                self.tableView.reloadData()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refsAndTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == refsAndTitles.count - 1 {
            loadMorePosts()
        }

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        )

        cell.textLabel?.text = refsAndTitles[indexPath.row].title
        return cell
    }

    @discardableResult private func loadMorePosts() {
        guard let nextPage = nextPage else { return }

        Post.loadRefsAndTitles(cursor: nextPage).map(at: .main) { [weak self] page in
            self?.refsAndTitles.append(contentsOf: page.refsAndTitles)
            self?.nextPage = page.nextPage
            self?.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let viewPost = segue.destination as? ViewPostController,
            let selectedPost = sender as? UITableViewCell,
            let selectedIndex = tableView.indexPath(for: selectedPost)
            else { return }

        viewPost.refAndTitle = refsAndTitles[selectedIndex.row]
        viewPost.postUpdatedCallback = postUpdated
    }

    @IBAction func unwindToListPosts(sender: UIStoryboardSegue) {
        if let editPost = sender.source as? EditPostController {
            newPostAdded(editPost)
            return
        }

        if let viewPost = sender.source as? ViewPostController {
            if sender.identifier == "postDeleted" {
                postDeleted(viewPost)
                return
            }
        }
    }

    private func newPostAdded(_ editPost: EditPostController) {
        guard let postAdded = editPost.post?.refAndTitle else { return }
        refsAndTitles.insert(postAdded, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    }

    private func postDeleted(_ viewPost: ViewPostController) {
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        refsAndTitles.remove(at: selectedRow.row)
        tableView.deleteRows(at: [selectedRow], with: .fade)
    }

    private func postUpdated(post: Post) {
        guard
            let selectedRow = tableView.indexPathForSelectedRow,
            let postUpdated = post.refAndTitle
            else { return }

        refsAndTitles[selectedRow.row] = postUpdated
        tableView.reloadRows(at: [selectedRow], with: .none)
    }

}
