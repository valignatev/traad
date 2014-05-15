import json
import os
import sys
import time
import unittest

import webtest

import traad.server
from traad.test import common


def wait_for_task(task_id, app):
    while True:
        resp = app.get('/task/{}'.format(task_id))

        if resp.json['status'] == 'success':
            return True
        elif resp.json['status'] == 'failure':
            return False

        time.sleep(0.01)


@unittest.skipUnless(sys.version_info.major == 3,
                     'Only run for Python version 3+')
class JSONAPITests(unittest.TestCase):
    def setUp(self):
        common.activate({'main': ['basic']})
        self.traad_app = traad.server.make_app(common.activated_path('main'))
        self.app = webtest.TestApp(self.traad_app)

    def tearDown(self):
        traad.server.stop_app(self.traad_app)
        common.deactivate()

    def test_rename(self):
        resp = self.app.post_json(
            '/refactor/rename',
            {
                'name': 'Llama',
                'path': 'basic/foo.py',
                'offset': 8,
            })

        self.assertEqual(resp.json['result'], 'success')
        task_id = resp.json['task_id']

        self.assertTrue(
            wait_for_task(task_id, self.app))

        common.compare_projects(
            'basic_rename_llama',
            'main',
            'basic')

    def test_find_occurrences(self):
        resp = self.app.post_json(
            '/findit/occurrences',
            {
                'path': 'basic/foo.py',
                'offset': 8,
            })
        self.assertEqual(len(resp.json['data']), 3)

    def test_find_implementations(self):
        resp = self.app.post_json(
            '/findit/implementations',
            {
                'path': 'basic/overrides.py',
                'offset': 33,
            })
        self.assertEqual(len(resp.json['data']), 1)

    def test_find_definition(self):
        path = os.path.join(
            common.activated_path('main'),
            'basic', 'bar.py')
        with open(path, 'r') as f:
            code = f.read()

        resp = self.app.post_json(
            '/findit/definition',
            {
                'code': code,
                'path': 'basic/bar.py',
                'offset': 142,
            })

        self.assertEqual(
            resp.json['data'],
            [os.path.join('basic', 'bar.py'),
             [91, 100],
             91,
             False,
             7])

    def test_undo_undoes_changes(self):
        resp = self.app.post_json(
            '/refactor/rename',
            {
                'name': 'Llama',
                'path': 'basic/foo.py',
                'offset': 8,
            })

        if resp.json['result'] != 'success':
            print(resp.json['message'])
        self.assertEqual(resp.json['result'], 'success')
        task_id = resp.json['task_id']

        self.assertTrue(
            wait_for_task(task_id, self.app))

        with self.assertRaises(ValueError):
            common.compare_projects(
                'basic',
                'main',
                'basic')

        resp = self.app.post_json(
            '/history/undo',
            {'index': 0})

        self.assertEqual(resp.json['result'], 'success')

        common.compare_projects(
            'basic',
            'main',
            'basic')

if __name__ == '__main__':
    unittest.main()
